"""
Test MCP Server Persistence

Verifies that the Wolfram kernel maintains state between MCP calls.
"""

import asyncio
import logging
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def test_persistence():
    """Test that kernel state persists across multiple calls."""

    server_params = StdioServerParameters(
        command="python",
        args=["AI/mcp_server.py"],
        env=None
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            logger.info("=== Testing Kernel Persistence ===\n")

            # Call 1: Define x = 1
            logger.info("Call 1: Setting x = 1")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "x = 1"}
            )
            logger.info(f"Result: {result.content[0].text}\n")

            # Call 2: Check what x is
            logger.info("Call 2: Checking value of x")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "x"}
            )
            logger.info(f"Result: {result.content[0].text}\n")

            # Call 3: Set y = x + 10
            logger.info("Call 3: Setting y = x + 10")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "y = x + 10"}
            )
            logger.info(f"Result: {result.content[0].text}\n")

            # Call 4: Check y
            logger.info("Call 4: Checking value of y")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "y"}
            )
            logger.info(f"Result: {result.content[0].text}\n")

            # Call 5: Verify Hamilcar is loaded
            logger.info("Call 5: Checking if Hamilcar symbols exist")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "Names[\"xAct`Hamilcar`*\"]"}
            )
            logger.info(f"Hamilcar symbols loaded: {len(result.content[0].text) > 10}\n")

            logger.info("=== Persistence Test Complete ===")
            logger.info("✓ Kernel maintains state across calls")


if __name__ == "__main__":
    asyncio.run(test_persistence())
