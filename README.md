# Warcraft III Sound Hook for Claude Code (Windows)

Hear Warcraft III worker voice lines while you code with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

When you send a prompt, a random race's worker says their **accept** line (*"Yes, milord"*, *"Something need doing?"*, *"I wish only to serve"*). When Claude needs your attention — a permission request — you hear an **ask** line (*"What is it?"*, *"What you want?"*). When Claude finishes, that same race's worker announces **work complete** (*"Job's done"*, *"Work complete"*, *"Ready to serve"*).

## Install

```powershell
git clone <repo-url>
cd claude_wc
.\install_windows.ps1
```

Restart Claude Code. That's it.

## What the installer does

1. Copies sound files to `~/.claude/wc3sounds/`
2. Copies hook scripts to `~/.claude/`
3. Creates `~/.claude/wc3_config.json` (default race weights)
4. Adds hooks to `~/.claude/settings.json`

## Configuration

Edit `~/.claude/wc3_config.json` to change race weights:

```json
{
  "races": {
    "orc": 60,
    "human": 20,
    "undead": 20
  }
}
```

Numbers are relative weights — they don't need to sum to 100. Add `"nightelf": 10` to include Night Elf wisps. Set a race to `0` to disable it. Re-running the installer preserves your config.

## Sound files

| Race | Accept | Ask | Complete |
|------|--------|-----|----------|
| **Orc** (Peon) | *"Something need doing?"*, *"What you want?"* ... (8 clips) | *"What?"* lines (4 clips) | *"Work complete"* |
| **Human** (Peasant) | *"Yes, milord"*, *"More work?"* ... (8 clips) | *"What?"* lines (4 clips) | *"Job's done"* |
| **Undead** (Acolyte) | *"I wish only to serve"*, *"Thy bidding, master?"* ... (9 clips) | *"What?"* lines (5 clips) | *"Ready to serve"* |
| **Night Elf** (Wisp) | *(mystical wisp sounds)* (6 clips) | *(wisp sounds)* (3 clips) | *(wisp ready sound)* |

## How it works

Uses [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — shell commands that run on specific events:

| Hook event | When it fires | Sound played |
|------------|---------------|--------------|
| `UserPromptSubmit` | You send a prompt | Accept voice line |
| `Notification` / `PermissionRequest` | Claude asks for permission | Ask voice line |
| `Stop` | Claude finishes responding | Complete voice line |

The accept hook picks a random race (weighted by config) and saves it to a temp file. The ask and complete hooks read that file so all sounds in a session match the same race.

## Credits

Sound files are from Warcraft III: Reign of Chaos by Blizzard Entertainment. This project is a fan-made tool for personal use and is not affiliated with or endorsed by Blizzard Entertainment.

Based on [warcraft3-claude-code-sound-hook](https://github.com/warmwind/warcraft3-claude-code-sound-hook) by warmwind (macOS version).
