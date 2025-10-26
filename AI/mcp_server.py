"""
Hamilcar MCP Server

Model Context Protocol server providing AI agents with access to
Hamilcar canonical field theory computations.
"""

import logging
import os
from typing import Any
from dotenv import load_dotenv

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

from tools.wolfram_kernel import WolframKernelManager

# Load environment variables
load_dotenv("AI/config/.env")

# Configure logging with colored timestamps
GRAY = '\033[90m'
RESET = '\033[0m'

class ColoredFormatter(logging.Formatter):
    def format(self, record):
        # Color the timestamp part gray
        original = super().format(record)
        # Split at first space after timestamp (format: "YYYY-MM-DD HH:MM:SS,mmm - ...")
        parts = original.split(' - ', 1)
        if len(parts) == 2:
            timestamp = parts[0]
            rest = parts[1]
            return f"{GRAY}{timestamp}{RESET} - {rest}"
        return original

handler = logging.StreamHandler()
handler.setFormatter(ColoredFormatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s"))
logging.basicConfig(
    level=os.getenv("AGENT_LOG_LEVEL", "INFO"),
    handlers=[handler]
)
logger = logging.getLogger(__name__)

# Initialize MCP server
app = Server("hamilcar-mcp")

# Global kernel manager (initialized on first tool call)
kernel_manager: WolframKernelManager = None


def ensure_kernel() -> WolframKernelManager:
    """Ensure Wolfram kernel is running."""
    global kernel_manager
    if kernel_manager is None:
        kernel_path = os.getenv("MATHEMATICA_KERNEL_PATH", "wolframkernel")
        kernel_manager = WolframKernelManager(kernel_path)
        kernel_manager.start()
        kernel_manager.load_hamilcar()
    return kernel_manager


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List available Hamilcar tools."""
    return [
        Tool(
            name="evaluate_wolfram",
            description="Evaluate arbitrary Wolfram Language code in the Hamilcar kernel",
            inputSchema={
                "type": "object",
                "properties": {
                    "code": {
                        "type": "string",
                        "description": "Wolfram Language code to evaluate"
                    }
                },
                "required": ["code"]
            }
        ),
        Tool(
            name="define_canonical_field",
            description="Define a canonical field and its conjugate momentum using DefCanonicalField",
            inputSchema={
                "type": "object",
                "properties": {
                    "field_expr": {
                        "type": "string",
                        "description": "Field expression, e.g., 'Phi[]' for scalar or 'A[a]' for vector"
                    },
                    "field_symbol": {
                        "type": "string",
                        "description": "Display symbol for field (optional)"
                    },
                    "momentum_symbol": {
                        "type": "string",
                        "description": "Display symbol for conjugate momentum (optional)"
                    }
                },
                "required": ["field_expr"]
            }
        ),
        Tool(
            name="poisson_bracket",
            description="Compute Poisson bracket between two operators",
            inputSchema={
                "type": "object",
                "properties": {
                    "operator1": {
                        "type": "string",
                        "description": "First operator in Wolfram Language syntax"
                    },
                    "operator2": {
                        "type": "string",
                        "description": "Second operator in Wolfram Language syntax"
                    }
                },
                "required": ["operator1", "operator2"]
            }
        ),
        Tool(
            name="find_algebra",
            description="Determine constraint algebra coefficients using FindAlgebra",
            inputSchema={
                "type": "object",
                "properties": {
                    "ansatz": {
                        "type": "string",
                        "description": "Ansatz expression for algebra structure"
                    }
                },
                "required": ["ansatz"]
            }
        ),
        Tool(
            name="reload_hamilcar",
            description="Reload Hamilcar sources (useful during development)",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        Tool(
            name="restart_kernel",
            description="Restart the Wolfram kernel (clears all definitions)",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        )
    ]


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Handle tool calls."""
    kernel = ensure_kernel()

    try:
        if name == "evaluate_wolfram":
            code = arguments["code"]
            result = kernel.evaluate(code)
            return [TextContent(type="text", text=str(result))]

        elif name == "define_canonical_field":
            field_expr = arguments["field_expr"]
            field_symbol = arguments.get("field_symbol")
            momentum_symbol = arguments.get("momentum_symbol")

            # Build DefCanonicalField call
            options = []
            if field_symbol:
                options.append(f'FieldSymbol->"{field_symbol}"')
            if momentum_symbol:
                options.append(f'MomentumSymbol->"{momentum_symbol}"')

            options_str = ", " + ", ".join(options) if options else ""
            code = f"DefCanonicalField[{field_expr}{options_str}]"

            result = kernel.evaluate(code)
            return [TextContent(type="text", text=f"Field defined: {result}")]

        elif name == "poisson_bracket":
            op1 = arguments["operator1"]
            op2 = arguments["operator2"]
            code = f"PoissonBracket[{op1}, {op2}]"

            result = kernel.evaluate(code)
            return [TextContent(type="text", text=str(result))]

        elif name == "find_algebra":
            ansatz = arguments["ansatz"]
            code = f"FindAlgebra[{ansatz}]"

            result = kernel.evaluate(code)
            return [TextContent(type="text", text=str(result))]

        elif name == "reload_hamilcar":
            result = kernel.evaluate("RereadSources[]")
            return [TextContent(type="text", text="Hamilcar sources reloaded")]

        elif name == "restart_kernel":
            kernel.restart()
            return [TextContent(type="text", text="Kernel restarted and Hamilcar reloaded")]

        else:
            return [TextContent(type="text", text=f"Unknown tool: {name}")]

    except Exception as e:
        logger.error(f"Error in {name}: {e}", exc_info=True)
        return [TextContent(type="text", text=f"Error: {str(e)}")]


async def main():
    """Run the MCP server."""
    logger.info("Starting Hamilcar MCP Server")

    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )

    # Cleanup
    if kernel_manager is not None:
        kernel_manager.stop()
    logger.info("Hamilcar MCP Server stopped")


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
