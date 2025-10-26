"""
Run Hamilcar Assistant Agent

Example script showing how to use the Hamilcar Assistant agent
with the MCP server.
"""

import asyncio
import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from agents import Agent, Runner
from agents.mcp import MCPServerStdio

# Load environment
load_dotenv("AI/config/.env")

# Add AI directory to path for local imports
ai_dir = Path(__file__).parent.parent
sys.path.insert(0, str(ai_dir))

# Import agent creator (use importlib to avoid naming conflict with 'agents' package)
import importlib.util
spec = importlib.util.spec_from_file_location("hamilcar_assistant", ai_dir / "hamilcar_agents" / "hamilcar_assistant.py")
hamilcar_assistant = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hamilcar_assistant)
create_hamilcar_assistant = hamilcar_assistant.create_hamilcar_assistant


async def run_agent_example():
    """Run example interaction with Hamilcar Assistant."""

    print("=" * 60)
    print("Hamilcar Assistant - Example Session")
    print("=" * 60)

    # Get project root
    project_root = Path(__file__).parent.parent.parent

    # Create MCP server connection (stdio-based)
    async with MCPServerStdio(
        name="Hamilcar MCP Server",
        params={
            "command": "python",
            "args": [str(project_root / "AI" / "mcp_server.py")],
            "env": None  # Inherits current environment
        },
        client_session_timeout_seconds=30  # Increase timeout for complex calculations
    ) as mcp_server:

        # Create agent with MCP server
        agent = create_hamilcar_assistant()
        agent.mcp_servers = [mcp_server]

        print("\nOK: Connected to Hamilcar MCP Server")
        print(f"OK: Agent: {agent.name}")
        print(f"OK: Model: {agent.model}")

        # Example 1: Define a scalar field
        print("\n" + "=" * 60)
        print("Example 1: Define a scalar field")
        print("=" * 60)
        print("\nUser: Define a scalar field called phi")

        result = await Runner.run(
            agent,
            "Define a scalar field called phi with field symbol φ and momentum symbol π"
        )

        print(f"\nAssistant:\n{result.final_output}")

        # Verify: Check if field actually exists by directly querying MCP
        print("\nVerification: Direct MCP query (bypassing agent interpretation)...")

        # Direct MCP call to check field exists
        verify_field = await mcp_server.call_tool("evaluate_wolfram", {"code": "Phi[]"})
        field_result = verify_field.content[0].text
        print(f"   Phi[] → {field_result}")
        print(f"   OK: Field exists: {('Phi' in field_result or 'φ' in field_result)}")

        # Direct MCP call to check momentum exists
        verify_mom = await mcp_server.call_tool("evaluate_wolfram", {"code": "ConjugateMomentumPhi[]"})
        mom_result = verify_mom.content[0].text
        print(f"   ConjugateMomentumPhi[] → {mom_result}")
        print(f"   OK: Momentum exists: {('ConjugateMomentumPhi' in mom_result or 'π' in mom_result)}")

        # Example 2: Compute Poisson bracket
        print("\n" + "=" * 60)
        print("Example 2: Compute canonical bracket")
        print("=" * 60)
        print("\nUser: What is the Poisson bracket of phi with its conjugate momentum?")

        result = await Runner.run(
            agent,
            "What is the Poisson bracket of Phi[] with ConjugateMomentumPhi[]?"
        )

        print(f"\nAssistant:\n{result.final_output}")

        # Verify: Check bracket result by directly calling MCP
        print("\nVerification: Direct MCP query for bracket...")
        verify_bracket = await mcp_server.call_tool("evaluate_wolfram", {
            "code": "PoissonBracket[Phi[], ConjugateMomentumPhi[]]"
        })
        bracket_result = verify_bracket.content[0].text
        print(f"   PoissonBracket result: {bracket_result[:100]}...")
        print(f"   OK: Contains delta function: {'delta' in bracket_result.lower()}")

        # Example 3: Check kernel state
        print("\n" + "=" * 60)
        print("Example 3: Query kernel state")
        print("=" * 60)
        print("\nUser: What is the value of $DynamicalMetric?")

        result = await Runner.run(
            agent,
            "What is the current value of the global variable $DynamicalMetric?"
        )

        print(f"\nAssistant:\n{result.final_output}")

    print("\n" + "=" * 60)
    print("Session complete!")
    print("=" * 60)


if __name__ == "__main__":
    # Check if API key is set
    if not os.getenv("OPENAI_API_KEY") or os.getenv("OPENAI_API_KEY") == "your-api-key-here":
        print("⚠️  Please set OPENAI_API_KEY in AI/config/.env")
        print("   Get your key from: https://platform.openai.com/api-keys")
    else:
        asyncio.run(run_agent_example())
