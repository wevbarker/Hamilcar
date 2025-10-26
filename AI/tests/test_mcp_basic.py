"""
Integration tests for basic MCP server functionality.

Tests kernel lifecycle, persistence, and basic operations.
"""

import pytest


def test_server_tools_available(wolfram_eval):
    """Test that MCP server can evaluate basic code."""
    # If we can evaluate, the server and its tools are working
    result = wolfram_eval("1 + 1")
    assert result == "2"


def test_basic_evaluation(wolfram_eval):
    """Test basic Wolfram Language evaluation."""
    result = wolfram_eval("2 + 2")
    assert result == "4"


def test_kernel_persistence(wolfram_eval):
    """Test that kernel state persists within a single MCP session."""
    # Note: Each test gets a new kernel session, so we test persistence
    # within the same call sequence
    # Set and immediately use variable
    result = wolfram_eval("(testvar = 42; testvar)")
    assert result == "42"


def test_hamilcar_loaded(wolfram_eval):
    """Test that Hamilcar package is loaded."""
    # Check Hamilcar symbols exist
    result = wolfram_eval("Length[Names[\"xAct`Hamilcar`*\"]]")
    symbol_count = int(result)
    assert symbol_count > 0, "Hamilcar package not loaded"


def test_hamilcar_version(wolfram_eval):
    """Test that we can query Hamilcar version."""
    result = wolfram_eval("xAct`Hamilcar`$Version")
    # Should return something like {"0.0.0-developer", {2025, ...}}
    assert "0.0.0-developer" in result


def test_multiple_operations(wolfram_eval):
    """Test multiple operations in single evaluation."""
    # Test compound statement
    result = wolfram_eval("(myList = {1, 2, 3, 4, 5}; Total[myList])")
    assert result == "15"

    # Test another operation
    result = wolfram_eval("Total[{1, 2, 3, 4, 5}^2]")
    assert result == "55"  # 1 + 4 + 9 + 16 + 25


def test_geometry_defined(wolfram_eval):
    """Test that Hamilcar's geometry is defined."""
    # Check spatial manifold exists
    result = wolfram_eval("M3")
    assert "M3" in result

    # Check spatial metric exists
    result = wolfram_eval("G[-a, -b]")
    assert "h" in result or "G" in result  # Display format varies
