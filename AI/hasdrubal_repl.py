#!/usr/bin/env python3
"""
Hasdrubal Interactive REPL with Split Panes

Interactive command-line interface for the Hasdrubal agent.
Uses split terminal view: upper pane for logs, lower for conversation.

Usage:
    source venv/bin/activate
    python AI/hasdrubal_repl.py
"""

import asyncio
import os
import sys
import logging
from pathlib import Path
from dotenv import load_dotenv
from datetime import datetime
from collections import deque

# Load environment
load_dotenv("AI/config/.env")

# Add AI directory to path for local imports
ai_dir = Path(__file__).parent
sys.path.insert(0, str(ai_dir))

# Import agent creator
import importlib.util
spec = importlib.util.spec_from_file_location("hamilcar_assistant", ai_dir / "hamilcar_agents" / "hamilcar_assistant.py")
hamilcar_assistant = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hamilcar_assistant)
create_hamilcar_assistant = hamilcar_assistant.create_hamilcar_assistant

# Import from agents package
from agents import Agent, Runner
from agents.mcp import MCPServerStdio

# ANSI codes
GRAY = '\033[90m'
RESET = '\033[0m'
CLEAR_SCREEN = '\033[2J'
MOVE_CURSOR = '\033[{};{}H'  # row, col
CLEAR_TO_END = '\033[0J'


class SplitPaneDisplay:
    """Manages split-pane terminal display."""

    def __init__(self, term_height=40, split_ratio=0.65):
        self.term_height = term_height
        self.split_row = int(term_height * split_ratio)

        # Buffers for each pane
        self.log_buffer = deque(maxlen=self.split_row - 2)
        self.conv_buffer = deque(maxlen=term_height - self.split_row - 3)

    def init_display(self):
        """Initialize the split display."""
        print(CLEAR_SCREEN, end='')
        self.draw_divider()

    def draw_divider(self):
        """Draw horizontal divider between panes."""
        print(MOVE_CURSOR.format(self.split_row, 1), end='')
        print("=" * 120, end='', flush=True)

    def add_log(self, text):
        """Add text to upper (log) pane."""
        self.log_buffer.append(text)
        self.redraw_log_pane()
        self.restore_cursor_to_input()

    def add_conv(self, text):
        """Add text to lower (conversation) pane."""
        # Wrap long lines to fit within terminal width
        max_width = 118  # Leave some margin
        if len(text) > max_width:
            # Split into multiple lines
            words = text.split()
            current_line = ""
            for word in words:
                if len(current_line) + len(word) + 1 <= max_width:
                    current_line += word + " "
                else:
                    if current_line:
                        self.conv_buffer.append(current_line.rstrip())
                    current_line = word + " "
            if current_line:
                self.conv_buffer.append(current_line.rstrip())
        else:
            self.conv_buffer.append(text)
        self.redraw_conv_pane()
        self.restore_cursor_to_input()

    def restore_cursor_to_input(self):
        """Restore cursor to input row."""
        print(MOVE_CURSOR.format(self.get_input_row(), 3), end='', flush=True)

    def redraw_log_pane(self):
        """Redraw entire upper pane."""
        # Clear upper pane
        for i in range(self.split_row - 1):
            print(MOVE_CURSOR.format(i + 1, 1), end='')
            print(' ' * 120, end='')

        # Draw log content
        for i, line in enumerate(self.log_buffer):
            if i >= self.split_row - 1:
                break
            print(MOVE_CURSOR.format(i + 1, 1), end='')
            print(line[:120], end='', flush=True)

    def redraw_conv_pane(self):
        """Redraw entire lower pane."""
        start_row = self.split_row + 1

        # Clear lower pane
        for i in range(self.term_height - self.split_row - 1):
            row = start_row + i
            print(MOVE_CURSOR.format(row, 1), end='')
            print(' ' * 120, end='')

        # Draw conversation content
        for i, line in enumerate(self.conv_buffer):
            row = start_row + i
            if row >= self.term_height:
                break
            print(MOVE_CURSOR.format(row, 1), end='')
            print(line[:120], end='', flush=True)

    def get_input_row(self):
        """Get row number for input prompt."""
        return self.term_height - 1


class LogCapture(logging.Handler):
    """Custom logging handler that captures to display."""

    def __init__(self, display):
        super().__init__()
        self.display = display

    def emit(self, record):
        try:
            msg = self.format(record)
            self.display.add_log(msg)
        except Exception:
            self.handleError(record)


async def interactive_loop(agent, display, mcp_server):
    """Custom interactive loop with split display."""

    while True:
        # Position cursor at input row
        print(MOVE_CURSOR.format(display.get_input_row(), 1), end='')
        print(' ' * 120, end='')  # Clear line
        print(MOVE_CURSOR.format(display.get_input_row(), 1), end='')

        # Get user input
        try:
            user_input = input("> ").strip()
        except (EOFError, KeyboardInterrupt):
            break

        if user_input.lower() in ['quit', 'exit', 'q']:
            break

        if not user_input:
            continue

        # Add user prompt to conversation pane
        display.add_conv(f"> {user_input}")

        # Track Wolfram code for this turn
        wl_codes = []

        # Wrap call_tool to capture WL code
        original_call_tool = mcp_server.call_tool
        async def capture_call_tool(tool_name, arguments):
            timestamp = datetime.now().strftime('%H:%M:%S.%f')[:-3]

            # Build WL code representation
            wl_code = None
            if tool_name == "evaluate_wolfram":
                wl_code = arguments.get('code', 'N/A')
            elif tool_name == "define_canonical_field":
                field_expr = arguments.get('field_expr', '?')
                field_symbol = arguments.get('field_symbol')
                momentum_symbol = arguments.get('momentum_symbol')
                options = []
                if field_symbol:
                    options.append(f'FieldSymbol->"{field_symbol}"')
                if momentum_symbol:
                    options.append(f'MomentumSymbol->"{momentum_symbol}"')
                options_str = ", " + ", ".join(options) if options else ""
                wl_code = f"DefCanonicalField[{field_expr}{options_str}]"
            elif tool_name == "poisson_bracket":
                op1 = arguments.get('operator1', '?')
                op2 = arguments.get('operator2', '?')
                wl_code = f"PoissonBracket[{op1}, {op2}]"
            else:
                wl_code = f"{tool_name}({arguments})"

            # Add to log pane
            display.add_log(f"{GRAY}[{timestamp}]{RESET} WOLFRAM: {wl_code}")

            # Store for conversation pane
            if wl_code and tool_name in ["evaluate_wolfram", "define_canonical_field", "poisson_bracket"]:
                wl_codes.append(wl_code)

            # Execute
            result = await original_call_tool(tool_name, arguments)

            # Log result
            if hasattr(result, 'content') and result.content:
                result_text = result.content[0].text
                if len(result_text) > 150:
                    result_text = result_text[:150] + "..."
                display.add_log(f"{GRAY}[{timestamp}]{RESET} RESULT: {result_text}")

            return result

        mcp_server.call_tool = capture_call_tool

        # Run agent
        try:
            result = await Runner.run(agent, user_input)

            # Show WL codes in conversation pane
            if wl_codes:
                display.add_conv("")
                display.add_conv("Wolfram Code:")
                for code in wl_codes:
                    display.add_conv(f"  {code}")
                display.add_conv("")

            # Show agent response in conversation pane
            response = result.final_output
            display.add_conv(f"Hasdrubal: {response}")
            display.add_conv("")

        except Exception as e:
            display.add_conv(f"Error: {str(e)}")
            display.add_log(f"ERROR: {str(e)}")

        # Restore original call_tool
        mcp_server.call_tool = original_call_tool


async def main():
    """Start split-pane REPL with Hasdrubal."""

    # Check API key
    if not os.getenv("OPENAI_API_KEY") or os.getenv("OPENAI_API_KEY") == "your-api-key-here":
        print("Please set OPENAI_API_KEY in AI/config/.env")
        print("Get your key from: https://platform.openai.com/api-keys")
        return

    project_root = ai_dir.parent

    # Get terminal size
    try:
        term_height = os.get_terminal_size().lines
    except:
        term_height = 40

    # Create display manager
    display = SplitPaneDisplay(term_height=term_height, split_ratio=0.65)

    # Configure logging to go to upper pane
    log_handler = LogCapture(display)
    log_handler.setFormatter(logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s"))

    logging.basicConfig(level=logging.INFO, handlers=[log_handler])
    logging.getLogger("mcp").setLevel(logging.INFO)
    logging.getLogger("tools").setLevel(logging.INFO)
    logging.getLogger("wolframclient").setLevel(logging.WARNING)

    # Initialize display
    display.init_display()
    display.add_conv("=" * 60)
    display.add_conv("Hasdrubal - Interactive Hamilcar Assistant")
    display.add_conv("Split Pane Mode: Logs above, conversation below")
    display.add_conv("=" * 60)
    display.add_conv("")
    display.add_conv("Starting MCP server and connecting to Wolfram kernel...")
    display.add_conv("(This may take a few seconds)")
    display.add_conv("")

    # Create MCP server connection
    async with MCPServerStdio(
        name="Hamilcar MCP Server",
        params={
            "command": "python",
            "args": [str(project_root / "AI" / "mcp_server.py")],
            "env": None
        },
        client_session_timeout_seconds=60
    ) as mcp_server:

        # Create agent with MCP server
        agent = create_hamilcar_assistant()
        agent.mcp_servers = [mcp_server]

        display.add_conv("Connected to Hamilcar MCP Server")
        display.add_conv(f"Agent: {agent.name}")
        display.add_conv(f"Model: {agent.model}")
        display.add_conv("")
        display.add_conv("Ready! Type 'quit' or 'exit' to stop.")
        display.add_conv("")

        # Run interactive loop
        await interactive_loop(agent, display, mcp_server)

        # Cleanup display
        print(MOVE_CURSOR.format(term_height, 1), end='')
        print("\n\nGoodbye!\n")


if __name__ == "__main__":
    asyncio.run(main())
