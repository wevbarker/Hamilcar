"""
Test MCP Client for Hamilcar

Simple client to test the Hamilcar MCP server.
"""

import asyncio
import logging
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def test_hamilcar_server():
    """Test the Hamilcar MCP server."""

    # Server parameters - run the MCP server as subprocess
    server_params = StdioServerParameters(
        command="python",
        args=["AI/mcp_server.py"],
        env=None
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize
            await session.initialize()

            # List available tools
            logger.info("Listing available tools...")
            tools_list = await session.list_tools()
            logger.info(f"Available tools: {[tool.name for tool in tools_list.tools]}")

            # Test 1: Define a scalar field
            logger.info("\n=== Test 1: Define scalar field ===")
            result = await session.call_tool(
                "define_canonical_field",
                arguments={
                    "field_expr": "Phi[]",
                    "field_symbol": "φ",
                    "momentum_symbol": "π"
                }
            )
            logger.info(f"Result: {result.content[0].text}")

            # Test 2: Compute Poisson bracket
            logger.info("\n=== Test 2: Poisson bracket ===")
            result = await session.call_tool(
                "poisson_bracket",
                arguments={
                    "operator1": "Phi[]",
                    "operator2": "ConjugateMomentumPhi[]"
                }
            )
            logger.info(f"Result: {result.content[0].text}")

            # Test 3: Evaluate arbitrary Wolfram code
            logger.info("\n=== Test 3: Evaluate Wolfram code ===")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={
                    "code": "2 + 2"
                }
            )
            logger.info(f"Result: {result.content[0].text}")

            logger.info("\n=== All tests completed ===")


if __name__ == "__main__":
    asyncio.run(test_hamilcar_server())
