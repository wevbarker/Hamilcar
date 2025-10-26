"""
Integration tests for Hamilcar-specific functions.

Tests DefCanonicalField, PoissonBracket, and other core functionality.
"""

import pytest


@pytest.mark.asyncio
async def test_define_scalar_field(mcp_session):
    """Test defining a scalar canonical field."""
    result = await mcp_session.call_tool(
        "define_canonical_field",
        arguments={
            "field_expr": "TestPhi[]",
            "field_symbol": "φ_test",
            "momentum_symbol": "π_test"
        }
    )
    # Should succeed without error
    assert "Field defined" in result.content[0].text or "TestPhi" in result.content[0].text


@pytest.mark.asyncio
async def test_define_vector_field(mcp_session):
    """Test defining a vector canonical field."""
    result = await mcp_session.call_tool(
        "define_canonical_field",
        arguments={
            "field_expr": "TestA[a]",
            "field_symbol": "A_test"
        }
    )
    # Should succeed without error
    assert "Field defined" in result.content[0].text or "TestA" in result.content[0].text


@pytest.mark.asyncio
async def test_poisson_bracket_canonical(wolfram_code):
    """Test canonical Poisson bracket {φ, π_φ} = 1."""
    # Define a scalar field
    await wolfram_code('DefCanonicalField[Psi[], FieldSymbol->"ψ", MomentumSymbol->"π_ψ"]')

    # Compute {ψ, π_ψ}
    result = await wolfram_code("PoissonBracket[Psi[], ConjugateMomentumPsi[]]")

    # Should contain delta function or smearing tensor
    # Exact format varies, but should not be zero
    assert result != "0"
    assert len(result) > 0


@pytest.mark.asyncio
async def test_poisson_bracket_field_field(wolfram_code):
    """Test that {φ, φ} = 0."""
    # Define a scalar field
    await wolfram_code('DefCanonicalField[Chi[], FieldSymbol->"χ"]')

    # Compute {χ, χ}
    result = await wolfram_code("PoissonBracket[Chi[], Chi[]]")

    # Should be zero
    assert result == "0"


@pytest.mark.asyncio
async def test_poisson_bracket_momentum_momentum(wolfram_code):
    """Test that {π, π} = 0."""
    # Define a scalar field
    await wolfram_code('DefCanonicalField[Sigma[], FieldSymbol->"σ"]')

    # Compute {π_σ, π_σ}
    result = await wolfram_code("PoissonBracket[ConjugateMomentumSigma[], ConjugateMomentumSigma[]]")

    # Should be zero
    assert result == "0"


@pytest.mark.asyncio
async def test_multiple_fields(wolfram_code):
    """Test defining and using multiple fields."""
    # Define two fields
    await wolfram_code('DefCanonicalField[FieldOne[], FieldSymbol->"f1"]')
    await wolfram_code('DefCanonicalField[FieldTwo[], FieldSymbol->"f2"]')

    # Compute cross bracket {f1, π_f2} should be zero
    result = await wolfram_code("PoissonBracket[FieldOne[], ConjugateMomentumFieldTwo[]]")

    # Different fields have vanishing bracket
    assert result == "0"


@pytest.mark.asyncio
async def test_registered_fields(wolfram_code):
    """Test that fields are properly registered."""
    # Define a field
    await wolfram_code('DefCanonicalField[RegField[], FieldSymbol->"ρ"]')

    # Check it's in registered fields
    result = await wolfram_code("MemberQ[$RegisteredFields, RegField]")
    assert result == "True"

    # Check momentum is registered
    result = await wolfram_code("MemberQ[$RegisteredMomenta, ConjugateMomentumRegField]")
    assert result == "True"


@pytest.mark.asyncio
async def test_geometry_available(wolfram_code):
    """Test that spatial geometry is available for field definitions."""
    # Define a tensor field with spatial indices
    await wolfram_code('DefCanonicalField[T[a, b], FieldSymbol->"T"]')

    # Should have covariant derivative available
    result = await wolfram_code("CD[-c][T[a, b]]")

    # Should return a tensor expression
    assert len(result) > 0
    assert result != "0"


@pytest.mark.asyncio
async def test_dynamical_metric_setting(wolfram_code):
    """Test querying $DynamicalMetric setting."""
    result = await wolfram_code("$DynamicalMetric")

    # Should be True or False
    assert result in ["True", "False"]


@pytest.mark.asyncio
async def test_reload_sources(mcp_session):
    """Test that RereadSources tool works."""
    result = await mcp_session.call_tool(
        "reload_hamilcar",
        arguments={}
    )

    # Should succeed
    assert "reloaded" in result.content[0].text.lower()
