# Hasdrubal Tmux Workflow

Interactive tmux-based workflow for the Hasdrubal AI assistant. Send prompts by saving a Vim buffer.

## Quick Start

```bash
cd ~/Documents/Hamilcar
source venv/bin/activate
./AI/hasdrubal
```

This creates a **new tmux session** with 3 panes:
- **Top pane (70%)**: Hasdrubal REPL with split display
- **Middle pane (2 lines)**: File watcher status
- **Bottom pane**: Vim editing `.PROMPT.txt`

The session is isolated and self-contained. When you exit, everything cleans up automatically.

## Workflow

1. **Write your prompt** in Vim (bottom pane)
2. **Save the file** (`:w`)
3. **Watch the REPL respond** (top pane)

The watcher automatically detects when you save `.PROMPT.txt` and sends the content to the REPL.

## Configuration

Environment variables (set before running `./AI/hasdrubal`):

- `HASDRUBAL_TOP_PCT` (default: `70`): Height percentage for REPL pane
- `HASDRUBAL_MID_LINES` (default: `2`): Number of lines for watcher pane

Example:
```bash
export HASDRUBAL_TOP_PCT=80
./AI/hasdrubal
```

Or use the `-p` flag:
```bash
./AI/hasdrubal -p 80
```

## Files

- `.PROMPT.txt`: Your prompt buffer (created automatically)
- `.hasdrubal.log`: Watcher activity log

## Requirements

- tmux
- Python virtual environment with Hasdrubal dependencies
- Optional: `inotifywait` (for instant file change detection; falls back to polling if unavailable)

## Tips

### Multiple Prompts
After the REPL responds, you can:
- Edit `.PROMPT.txt` again and save to send another prompt
- The conversation history is maintained in the REPL

### Manual Input
You can still type directly into the REPL (top pane) if needed. Just switch to that pane with tmux keybindings (e.g., `Ctrl-b` + arrow keys).

### Exit

**Single command cleanup** - Any of these will close all panes and return you to your original tmux location:
- Press `Ctrl-C` in the watcher pane (middle)
- Press `Ctrl-Z` in the watcher pane
- Quit vim with `:qa!` and the session auto-closes

When the watcher exits, the entire hasdrubal session terminates automatically.

## Architecture

```
┌─────────────────────────────────────────┐
│  Hasdrubal REPL (split pane)            │
│  ┌─────────────────────────────────┐    │
│  │ Logs (MCP, kernel, timestamps)  │    │
│  ├─────────────────────────────────┤    │
│  │ Conversation (prompts, WL code, │    │
│  │              agent responses)    │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  Watcher: Monitoring .PROMPT.txt        │
├─────────────────────────────────────────┤
│  Vim: .PROMPT.txt                        │
│                                          │
│  Your prompt here...                     │
└─────────────────────────────────────────┘
```

## Example Session

```bash
# Terminal 1: Launch tmux workflow
cd ~/Documents/Hamilcar
source venv/bin/activate
./AI/hasdrubal

# Vim (bottom pane): Type prompt
Define a scalar field Phi with field symbol φ

# Save with :w

# Top pane shows:
> Define a scalar field Phi with field symbol φ

Wolfram Code:
  DefCanonicalField[Phi[], FieldSymbol->"φ", MomentumSymbol->"π"]

Hasdrubal: The scalar field φ and its conjugate momentum π have been defined successfully.

# Continue the conversation by editing .PROMPT.txt again
```

## Troubleshooting

**REPL doesn't start**: Make sure you're in the Hamilcar project root and have activated the venv before running `./AI/hasdrubal`.

**Watcher shows errors**: Check `.hasdrubal.log` for details. Ensure tmux pane IDs are valid.

**Prompts not sending**: Verify `.PROMPT.txt` exists and is being saved. Try `:w!` in Vim to force a write.
