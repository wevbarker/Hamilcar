"""
Pytest configuration and fixtures for Hamilcar MCP tests.
"""

import pytest


@pytest.fixture(scope="session")
def mcp_session_sync():
    """
    Synchronous wrapper - tests should use wolfram_eval fixture instead.
    """
    return None


@pytest.fixture
def wolfram_eval():
    """
    Provide a synchronous-style helper to evaluate Wolfram code via subprocess.

    This is simpler than async fixtures and works reliably with pytest.

    Usage:
        def test_something(wolfram_eval):
            result = wolfram_eval("2 + 2")
            assert result == "4"
    """
    import subprocess
    import json

    def evaluate(code: str) -> str:
        # Run evaluation via Python subprocess calling MCP
        script = f"""
import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def run():
    # Use AI/mcp_server.py relative to current working directory
    params = StdioServerParameters(command='python', args=['AI/mcp_server.py'], env=None)
    async with stdio_client(params) as (r, w):
        async with ClientSession(r, w) as session:
            await session.initialize()
            result = await session.call_tool('evaluate_wolfram', {{'code': {json.dumps(code)}}})
            print(result.content[0].text, end='')

asyncio.run(run())
"""
        import os
        project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
        result = subprocess.run(
            ['python', '-c', script],
            capture_output=True,
            text=True,
            timeout=30,
            cwd=project_root
        )
        if result.returncode != 0:
            raise Exception(f"Evaluation failed: {result.stderr}")
        return result.stdout.strip()

    return evaluate
