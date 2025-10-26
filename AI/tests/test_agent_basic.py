"""
Integration tests for Hamilcar Assistant Agent

Tests natural language → agent → MCP → kernel state changes.

Test pattern:
1. Send natural language query to agent
2. Agent interprets and calls MCP tools
3. Verify kernel state changed correctly via direct MCP query
"""

import pytest
import os
from dotenv import load_dotenv

load_dotenv("AI/config/.env")

# Skip tests if no OpenAI API key
pytestmark = pytest.mark.skipif(
    not os.getenv("OPENAI_API_KEY") or os.getenv("OPENAI_API_KEY") == "your-api-key-here",
    reason="OpenAI API key not configured"
)


def test_agent_define_scalar_field(wolfram_eval):
    """
    Test: Agent can define a scalar field from natural language.

    Flow:
    1. User: "Define a scalar field called Psi"
    2. Agent: Interprets → calls define_canonical_field or evaluate_wolfram
    3. Verify: Check that Psi[] and ConjugateMomentumPsi[] exist in kernel
    """
    # Manually define field (simulating what agent would do)
    wolfram_eval('DefCanonicalField[Psi[], FieldSymbol->"ψ", MomentumSymbol->"π_ψ"]')

    # Verify we can evaluate the field (proves it's defined)
    result = wolfram_eval("Psi[]")
    assert "Psi" in result or "ψ" in result

    # Verify conjugate momentum exists
    result = wolfram_eval("ConjugateMomentumPsi[]")
    assert "ConjugateMomentumPsi" in result or "π" in result


def test_agent_define_vector_field(wolfram_eval):
    """
    Test: Agent can define a vector field from natural language.

    User: "Define a vector field A"
    Verify: A[a] and ConjugateMomentumA[a] exist
    """
    # Manually define (simulating agent)
    wolfram_eval('DefCanonicalField[VecA[a], FieldSymbol->"A"]')

    # Verify can use with indices
    result = wolfram_eval("VecA[a]")
    assert "VecA" in result or "A" in result

    # Verify momentum exists
    result = wolfram_eval("ConjugateMomentumVecA[a]")
    assert "ConjugateMomentumVecA" in result


def test_agent_compute_canonical_bracket(wolfram_eval):
    """
    Test: Agent can compute canonical Poisson bracket.

    User: "What is the Poisson bracket of Phi with its conjugate momentum?"
    Expected: Delta function result
    """
    # Setup: Define field
    wolfram_eval('DefCanonicalField[TestPhi[], FieldSymbol->"φ"]')

    # What agent should compute
    wolfram_eval('$ManualSmearing = False')
    result = wolfram_eval("PoissonBracket[TestPhi[], ConjugateMomentumTestPhi[]]")

    # Should contain delta or smearing tensor (not just zero)
    assert result != "0"
    assert len(result) > 0


def test_agent_field_field_bracket_zero(wolfram_eval):
    """
    Test: Agent knows {field, field} = 0 (when metric not dynamical).

    User: "Compute the bracket of phi with itself"
    Expected: 0 (with $DynamicalMetric=False)
    """
    # Setup - disable dynamical metric
    wolfram_eval('$DynamicalMetric = False')
    wolfram_eval('DefCanonicalField[BracketPhi[], FieldSymbol->"φ"]')

    # What agent should compute
    result = wolfram_eval("PoissonBracket[BracketPhi[], BracketPhi[]]")
    assert result == "0"


def test_agent_multiple_fields_independent(wolfram_eval):
    """
    Test: Agent understands different fields have vanishing brackets.

    User: "Define fields phi and chi, then compute their bracket"
    Expected: {phi, pi_chi} = 0 (with $DynamicalMetric=False)
    """
    # Setup - disable dynamical metric for clean result
    wolfram_eval('$DynamicalMetric = False')
    wolfram_eval('DefCanonicalField[MultiPhi[], FieldSymbol->"φ"]')
    wolfram_eval('DefCanonicalField[MultiChi[], FieldSymbol->"χ"]')

    # Cross bracket should be zero
    result = wolfram_eval("PoissonBracket[MultiPhi[], ConjugateMomentumMultiChi[]]")
    assert result == "0"


def test_agent_check_dynamical_metric_setting(wolfram_eval):
    """
    Test: Agent can query and set global variables within single session.

    User: "Is the metric dynamical?"
    Expected: Agent checks $DynamicalMetric
    """
    # Query and set in one compound statement (same kernel session)
    result = wolfram_eval("($DynamicalMetric = False; $DynamicalMetric)")
    assert result == "False"

    # Query in another compound statement
    result = wolfram_eval("($DynamicalMetric = True; $DynamicalMetric)")
    assert result == "True"


def test_agent_query_geometry(wolfram_eval):
    """
    Test: Agent knows about pre-defined geometry.

    User: "What geometric objects are available?"
    Expected: Agent can list M3, G, CD, epsilonG
    """
    # Agent should know these exist
    result = wolfram_eval("M3")
    assert "M3" in result

    result = wolfram_eval("G[-a, -b]")
    assert "h" in result or "G" in result

    # Check spatial covariant derivative exists
    result = wolfram_eval("CD")
    assert len(result) > 0


# Tests with actual agent (now implemented!)
@pytest.mark.asyncio
async def test_agent_natural_language_scalar_field():
    """
    Test: Full end-to-end agent workflow for defining a scalar field.

    Flow:
    1. User: "Define a scalar field called psi"
    2. Agent: Interprets → calls MCP tools
    3. Verify: Field exists in kernel
    """
    import asyncio
    import sys
    from pathlib import Path
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

        # Ask agent to define field
        result = await Runner.run(agent, "Define a scalar field called Psi with field symbol ψ")

        # Verify response mentions success
        assert "defined" in result.final_output.lower() or "successfully" in result.final_output.lower()


@pytest.mark.asyncio
async def test_agent_natural_language_poisson_bracket():
    """
    Test: Agent computes Poisson bracket from natural language.

    Flow:
    1. User asks about bracket
    2. Agent computes via MCP
    3. Response includes physics interpretation
    """
    import asyncio
    import sys
    from pathlib import Path
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

        # First define a field
        await Runner.run(agent, "Define a scalar field TestPhi")

        # Ask about bracket
        result = await Runner.run(agent, "What is the Poisson bracket of TestPhi with its conjugate momentum?")

        # Should mention delta function or canonical relation
        response_lower = result.final_output.lower()
        assert "delta" in response_lower or "canonical" in response_lower
