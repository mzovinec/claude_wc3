# RTS Claude Code Sounds (Windows)

Hear RTS worker voice lines while you code with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Supports **Warcraft III** and **C&C Generals** worker/builder units.

When you send a prompt, a random unit says their **accept** line. When Claude needs your attention — a permission request — you hear an **ask** line. When Claude finishes, that same unit announces **complete**.

## Install

```powershell
git clone <repo-url>
cd claude_wc3
.\install_windows.ps1
```

Restart Claude Code. That's it.

## What the installer does

1. Copies sound files to `~/.claude/rtssounds/`
2. Copies hook scripts to `~/.claude/`
3. Creates `~/.claude/rts_config.json` (default game & faction weights)
4. Adds hooks to `~/.claude/settings.json`

## Configuration

Edit `~/.claude/rts_config.json` to change weights. Two-level system: set a game's weight to `0` to disable all its factions at once.

```json
{
  "games": {
    "wc3": {
      "weight": 50,
      "races": {
        "orc": 30,
        "human": 20,
        "undead": 20,
        "czech_human": 30
      }
    },
    "cnc": {
      "weight": 50,
      "races": {
        "China_Dozer": 30,
        "GLA_Worker": 40,
        "USA_Dozer": 30
      }
    }
  }
}
```

Numbers are relative weights — they don't need to sum to 100.

## Sound files

### Warcraft III

| Race | Accept | Ask | Complete |
|------|--------|-----|----------|
| **Orc** (Peon) | *"Something need doing?"*, *"What you want?"* ... (8 clips) | *"What?"* lines (4 clips) | *"Work complete"* |
| **Human** (Peasant) | *"Yes, milord"*, *"More work?"* ... (8 clips) | *"What?"* lines (4 clips) | *"Job's done"* |
| **Undead** (Acolyte) | *"I wish only to serve"*, *"Thy bidding, master?"* ... (9 clips) | *"What?"* lines (5 clips) | *"Ready to serve"* |
| **Czech Human** (Peasant) | Czech voice lines | Czech voice lines | *Uses English human complete sounds* |

### C&C Generals

| Faction | Accept (Move/Build) | Ask (Select) | Complete (BuildComplete) |
|---------|---------------------|--------------|--------------------------|
| **China Dozer** | Move & Build lines | Select lines | BuildComplete lines |
| **GLA Worker** | Move & Build lines | Select lines | BuildComplete lines |
| **USA Dozer** | Move & Build lines | Select lines | BuildComplete lines |

## How it works

Uses [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — shell commands that run on specific events:

| Hook event | When it fires | Sound played |
|------------|---------------|--------------|
| `UserPromptSubmit` | You send a prompt | Accept voice line |
| `Notification` / `PermissionRequest` | Claude asks for permission | Ask voice line |
| `Stop` | Claude finishes responding | Complete voice line |

The accept hook picks a random game (weighted), then a random faction within it, and saves the choice to a temp file. The ask and complete hooks read that file so all sounds in a turn match the same faction.

## Credits

- Warcraft III sounds from Warcraft III: Reign of Chaos by Blizzard Entertainment.
- C&C Generals sounds from Command & Conquer: Generals by EA Games.

This project is a fan-made tool for personal use and is not affiliated with or endorsed by Blizzard Entertainment or EA Games.

Based on [warcraft3-claude-code-sound-hook](https://github.com/warmwind/warcraft3-claude-code-sound-hook) by warmwind (macOS version).
