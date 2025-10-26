"""
Agent Verification Tests with Golden Reference Outputs

Tests that verify agent actions by comparing kernel state against
known-good reference outputs generated from pure WL scripts.
"""

import pytest
import re
import sys
from pathlib import Path


@pytest.mark.asyncio
async def test_agent_scalar_field_vs_reference():
    """
    Test: Agent defines scalar field and computes bracket, verify against golden output.

    Reference: AI/tests/references/agent_scalar_field.m
    Golden output: AI/tests/references/agent_scalar_field.expected

    Verification:
    1. Ask agent to define field and compute bracket
    2. Query kernel state directly via MCP
    3. Compare with reference output patterns
    """
    import asyncio
    from agents import Runner
    from agents.mcp import MCPServerStdio

    # Import agent creator
    ai_dir = Path(__file__).parent.parent
    sys.path.insert(0, str(ai_dir))
    import importlib.util
    spec = importlib.util.spec_from_file_location("hamilcar_assistant", ai_dir / "hamilcar_agents" / "hamilcar_assistant.py")
    hamilcar_assistant = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(hamilcar_assistant)
    create_hamilcar_assistant = hamilcar_assistant.create_hamilcar_assistant

    project_root = ai_dir.parent

    # Read golden reference
    golden_file = ai_dir / "tests" / "references" / "agent_scalar_field.expected"
    with open(golden_file, 'r') as f:
        golden_output = f.read()

    # Extract expected values from golden output
    field_exists_match = re.search(r'FIELD_EXISTS:(\w+)', golden_output)
    momentum_exists_match = re.search(r'MOMENTUM_EXISTS:(\w+)', golden_output)
    bracket_result_match = re.search(r'BRACKET_RESULT:(.*)', golden_output)
    bracket_type_match = re.search(r'BRACKET_TYPE:(\w+)', golden_output)

    assert field_exists_match and field_exists_match.group(1) == "True"
    assert momentum_exists_match and momentum_exists_match.group(1) == "True"
    assert bracket_type_match and bracket_type_match.group(1) == "Times"

    # Start MCP server
    async with MCPServerStdio(
        name="Hamilcar MCP Server",
        params={
            "command": "python",
            "args": [str(project_root / "AI" / "mcp_server.py")],
            "env": None
        },
        client_session_timeout_seconds=30
    ) as mcp_server:
        agent = create_hamilcar_assistant()
        agent.mcp_servers = [mcp_server]

        # Step 1: Define field
        result1 = await Runner.run(
            agent,
            "Define a scalar field Phi with field symbol phi and momentum symbol pi."
        )

        # Step 2: Compute bracket and store (pure natural language except variable name)
        result2 = await Runner.run(
            agent,
            "Compute the Poisson bracket of Phi with its conjugate momentum and store the result in a variable called bracketResult."
        )

        # Agent gives natural language response - we don't verify this
        # Instead, verify kernel state directly

        # Check 1: Field exists
        field_check = await mcp_server.call_tool("evaluate_wolfram", {
            "code": "Head[Phi[]] =!= Symbol"
        })
        field_exists = field_check.content[0].text.strip()
        assert field_exists == "True", f"Field should exist, got: {field_exists}"

        # Check 2: Momentum exists
        momentum_check = await mcp_server.call_tool("evaluate_wolfram", {
            "code": "Head[ConjugateMomentumPhi[]] =!= Symbol"
        })
        momentum_exists = momentum_check.content[0].text.strip()
        assert momentum_exists == "True", f"Momentum should exist, got: {momentum_exists}"

        # Check 3: bracketResult variable exists and has correct type
        bracket_check = await mcp_server.call_tool("evaluate_wolfram", {
            "code": "bracketResult"
        })
        bracket_value = bracket_check.content[0].text.strip()

        # Should contain smearing functions (pattern: SmearingXXX[]*SmearingYYY[])
        assert "Smearing" in bracket_value, f"Bracket should contain smearing functions, got: {bracket_value}"

        # Check type is Times (product of two smearing functions)
        bracket_type_check = await mcp_server.call_tool("evaluate_wolfram", {
            "code": "Head[bracketResult]"
        })
        bracket_type = bracket_type_check.content[0].text.strip()
        assert bracket_type == "Times", f"Bracket should be Times (product), got: {bracket_type}"

        print(f"\nOK: Agent verification passed!")
        print(f"   Field exists: {field_exists}")
        print(f"   Momentum exists: {momentum_exists}")
        print(f"   Bracket stored in bracketResult: {bracket_value[:50]}...")
        print(f"   Bracket type: {bracket_type}")


@pytest.mark.asyncio
async def test_agent_can_query_stored_results():
    """
    Test: Agent stores computation result, then we verify it persists in kernel.

    This tests that:
    1. Agent correctly interprets "store in variable X"
    2. Agent executes the assignment
    3. Variable persists in kernel for later retrieval
    """
    import asyncio
    from agents import Runner
    from agents.mcp import MCPServerStdio

    # Import agent creator
    ai_dir = Path(__file__).parent.parent
    sys.path.insert(0, str(ai_dir))
    import importlib.util
    spec = importlib.util.spec_from_file_location("hamilcar_assistant", ai_dir / "hamilcar_agents" / "hamilcar_assistant.py")
    hamilcar_assistant = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(hamilcar_assistant)
    create_hamilcar_assistant = hamilcar_assistant.create_hamilcar_assistant

    project_root = ai_dir.parent

    async with MCPServerStdio(
        name="Hamilcar MCP Server",
        params={
            "command": "python",
            "args": [str(project_root / "AI" / "mcp_server.py")],
            "env": None
        },
        client_session_timeout_seconds=30
    ) as mcp_server:
        agent = create_hamilcar_assistant()
        agent.mcp_servers = [mcp_server]

        # Ask agent to store $DynamicalMetric value in a variable
        result = await Runner.run(
            agent,
            "Get the value of $DynamicalMetric and store it in a variable called metricFlag"
        )

        # Directly verify the variable exists and has correct value
        check = await mcp_server.call_tool("evaluate_wolfram", {
            "code": "metricFlag"
        })
        stored_value = check.content[0].text.strip()

        # Should be True (default value)
        assert stored_value == "True", f"Expected metricFlag=True, got: {stored_value}"

        print(f"\nOK: Stored result verification passed!")
        print(f"   metricFlag = {stored_value}")
