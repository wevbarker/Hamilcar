"""
Integration tests for parallel kernel functionality.

Tests parallel kernel launching, execution, and cleanup.
"""

import pytest
import os


@pytest.mark.asyncio
async def test_license_limits(wolfram_code):
    """Test that we can query license limits."""
    result = await wolfram_code("$MaxLicenseSubprocesses")
    # Should be a number or DirectedInfinity[1] (unlimited)
    assert result is not None
    assert len(result) > 0


@pytest.mark.asyncio
async def test_launch_kernels(wolfram_code):
    """Test launching parallel kernels."""
    # Launch kernels
    await wolfram_code("LaunchKernels[]")

    # Check kernel count
    result = await wolfram_code("$KernelCount")
    kernel_count = int(result)
    assert kernel_count > 0, "No parallel kernels launched"

    # Cleanup
    await wolfram_code("CloseKernels[]")


@pytest.mark.asyncio
async def test_parallel_evaluation(wolfram_code):
    """Test that parallel evaluation works."""
    # Launch kernels
    await wolfram_code("LaunchKernels[]")

    # Get kernel IDs from each subkernel
    result = await wolfram_code("ParallelEvaluate[$KernelID]")
    # Should return list of kernel IDs like {1, 2, 3, ...}
    assert "{" in result

    # Cleanup
    await wolfram_code("CloseKernels[]")


@pytest.mark.asyncio
async def test_parallel_computation(wolfram_code):
    """Test parallel computation produces correct results."""
    # Launch kernels
    await wolfram_code("LaunchKernels[]")

    # Parallel sum
    result = await wolfram_code("ParallelSum[i, {i, 1, 100}]")
    assert result == "5050"  # Sum of 1 to 100

    # Parallel table
    result = await wolfram_code("Length[ParallelTable[i^2, {i, 1, 10}]]")
    assert result == "10"

    # Cleanup
    await wolfram_code("CloseKernels[]")


@pytest.mark.asyncio
async def test_subkernel_file_io(wolfram_code):
    """Test that subkernels can write to files."""
    # Clean up any existing test files
    test_files = "AI/sessions/test_kernel_*.txt"
    os.system(f"rm -f {test_files}")

    # Launch kernels
    await wolfram_code("LaunchKernels[]")

    # Have each subkernel write its ID
    await wolfram_code("""
        ParallelEvaluate[
            Export[
                "AI/sessions/test_kernel_" <> ToString[$KernelID] <> ".txt",
                "Kernel " <> ToString[$KernelID],
                "Text"
            ]
        ]
    """)

    # Check files exist
    result = await wolfram_code('Length[FileNames["test_kernel_*.txt", "AI/sessions"]]')
    file_count = int(result)
    assert file_count > 0, "Subkernels did not create files"

    # Cleanup
    await wolfram_code("CloseKernels[]")
    os.system(f"rm -f {test_files}")


@pytest.mark.asyncio
async def test_hamilcar_on_subkernels(wolfram_code):
    """Test that Hamilcar is loaded on all subkernels."""
    # Launch kernels
    await wolfram_code("LaunchKernels[]")

    # Check Hamilcar symbols exist on each subkernel
    result = await wolfram_code("""
        ParallelEvaluate[Length[Names["xAct`Hamilcar`*"]] > 0]
    """)

    # All subkernels should return True
    assert "False" not in result, "Hamilcar not loaded on some subkernels"

    # Cleanup
    await wolfram_code("CloseKernels[]")


@pytest.mark.asyncio
async def test_kernel_cleanup(wolfram_code):
    """Test that closing kernels works properly."""
    # Launch kernels
    await wolfram_code("LaunchKernels[]")

    # Verify kernels running
    result = await wolfram_code("$KernelCount")
    assert int(result) > 0

    # Close kernels
    await wolfram_code("CloseKernels[]")

    # Verify kernels closed
    result = await wolfram_code("$KernelCount")
    assert result == "0", "Kernels not properly closed"
