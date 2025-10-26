"""
Test Parallel Kernel Launch via MCP

Tests the Wolfram kernel's ability to launch parallel subkernels,
respecting license limits and confirming parallel execution.
"""

import asyncio
import logging
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def test_parallel_kernels():
    """Test parallel kernel launching and execution."""

    server_params = StdioServerParameters(
        command="python",
        args=["AI/mcp_server.py"],
        env=None
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            logger.info("=== Testing Parallel Kernel Launch ===\n")

            # Step 1: Check license limits
            logger.info("Step 1: Checking license limits")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "$MaxLicenseSubprocesses"}
            )
            max_subprocesses = result.content[0].text
            logger.info(f"Max license subprocesses: {max_subprocesses}\n")

            # Step 2: Launch parallel kernels
            logger.info("Step 2: Launching parallel kernels")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "LaunchKernels[]"}
            )
            logger.info(f"Kernels launched: {result.content[0].text}\n")

            # Step 3: Check how many kernels are running
            logger.info("Step 3: Counting active kernels")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "$KernelCount"}
            )
            kernel_count = result.content[0].text
            logger.info(f"Active parallel kernels: {kernel_count}\n")

            # Step 4: Check kernel IDs
            logger.info("Step 4: Getting kernel IDs")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "Kernels[]"}
            )
            logger.info(f"Kernel objects: {result.content[0].text}\n")

            # Step 5: Have each subkernel report its $KernelID
            logger.info("Step 5: Each subkernel reports its KernelID")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={
                    "code": """
                    ParallelEvaluate[$KernelID]
                    """
                }
            )
            logger.info(f"Subkernel IDs: {result.content[0].text}\n")

            # Step 6: Have each subkernel write to a file
            logger.info("Step 6: Subkernels write their IDs to files")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={
                    "code": """
                    ParallelEvaluate[
                        Export[
                            "AI/sessions/kernel_" <> ToString[$KernelID] <> ".txt",
                            "I am kernel " <> ToString[$KernelID],
                            "Text"
                        ]
                    ]
                    """
                }
            )
            logger.info(f"File write results: {result.content[0].text}\n")

            # Step 7: Verify files were created (from master kernel)
            logger.info("Step 7: Master kernel checks files exist")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={
                    "code": """
                    FileNames["kernel_*.txt", "AI/sessions"]
                    """
                }
            )
            logger.info(f"Created files: {result.content[0].text}\n")

            # Step 8: Test parallel computation
            logger.info("Step 8: Parallel computation test (sum 1 to 100)")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={
                    "code": """
                    ParallelSum[i, {i, 1, 100}]
                    """
                }
            )
            logger.info(f"Parallel sum result: {result.content[0].text}\n")

            # Step 9: Test Hamilcar is loaded on subkernels
            logger.info("Step 9: Check Hamilcar loaded on subkernels")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={
                    "code": """
                    ParallelEvaluate[
                        Length[Names["xAct`Hamilcar`*"]] > 0
                    ]
                    """
                }
            )
            logger.info(f"Hamilcar loaded on subkernels: {result.content[0].text}\n")

            # Step 10: Close parallel kernels
            logger.info("Step 10: Closing parallel kernels")
            result = await session.call_tool(
                "evaluate_wolfram",
                arguments={"code": "CloseKernels[]"}
            )
            logger.info(f"Kernels closed\n")

            logger.info("=== Parallel Test Complete ===")


if __name__ == "__main__":
    asyncio.run(test_parallel_kernels())
