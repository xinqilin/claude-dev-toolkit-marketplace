# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code plugin repository for Java/Spring Boot development. Contains 4 independent plugins installable via `install.sh`.

## Architecture

```
plugins/
  <plugin-name>/
    agents/<name>.md               # Agent definition (YAML frontmatter + instructions)
    skills/<skill-name>/           # Skill folder (slash command or knowledge base)
      SKILL.md                     # Core principles + YAML frontmatter
      references/                  # Optional: detailed reference docs
install.sh                         # Symlink installer (~/.claude/agents, ~/.claude/skills)
uninstall.sh                       # Remove symlinks
```

## Plugin Components

| Component | Location | Trigger | Purpose |
|-----------|----------|---------|---------|
| Agent | `agents/*.md` | Auto (conversation context) | Interactive assistance |
| Skill | `skills/*/SKILL.md` | `/name` or auto (topic detection) | Slash command or knowledge base |

## Key Files to Modify

- **Add new plugin**: Create folder under `plugins/`, define `agents/` and/or `skills/`
- **Modify plugin behavior**: Edit the corresponding `.md` file in agents or skills
- **Add new skill/command**: Create `skills/<name>/SKILL.md` with proper YAML frontmatter

## YAML Frontmatter Fields

Agent files (`agents/*.md`):
- `name`, `description`, `tools`, `model`
- `skills` - preload skills into agent context on startup
- `memory` - persistence level (`project` for cross-session learning)
- `disallowedTools` - explicitly forbid tools (e.g. reviewers forbid Edit, Write)

Skill files (`skills/*/SKILL.md`):
- `name` - determines the `/name` slash command
- `description` - trigger conditions
- `argument-hint` - shown in autocomplete
- `allowed-tools`, `model` - optional
- `user-invocable` - set `false` for knowledge-base skills (hidden from `/` menu)
- `context` - set `fork` for heavy skills that should run in isolated context

## Installation

Two approaches (both work):

**Via `/plugin` UI** (no clone needed):
```
/plugin marketplace add xinqilin/claude-dev-toolkit-marketplace
```

**Via `install.sh`** (after cloning, uses symlinks — auto-updates on `git pull`):
```bash
./install.sh --all              # Install all plugins
./install.sh --plugin <name>    # Install one plugin
./install.sh --list             # List available plugins
./uninstall.sh                  # Remove all symlinks
```

Symlinks target `~/.claude/agents/` and `~/.claude/skills/`.

## Gotchas

- `.claude-plugin/marketplace.json` 和 `plugin.json` 必須保留：`/plugin` UI 依賴這些檔案
- `/plugin` 讀取 GitHub repo，本地改動需 push 後才生效
- `install.sh` 寫入 `~/.claude/`，在沙盒模式下需要 `dangerouslyDisableSandbox: true`
- command → skill 轉換：在 frontmatter 加 `name` 欄位即可，其餘欄位照搬

## Orchestration Pattern

Agents preload skills via `skills` frontmatter. This means:
- Agent = persona + workflow + output format
- Skill = domain knowledge (preloaded or slash command)
- Agent 啟動 → skills 自動注入 → agent 獲得領域知識，無需使用者手動觸發

Example: `bill-java-developer` preloads `effective-java`, `clean-architecture`, `mysql-optimization`.

## Current Plugins

1. **bill-billing-unit-test-reviewer** - Unit test review (`/review-test`)
2. **bill-code-reviewer** - Code review (`/code-review`, `/review-pr`)
3. **bill-java-developer** - Spring Boot dev (`/design-solution`, `/optimize-query`)
4. **bill-java-skills** - Knowledge-base skills (preloaded by agents, not in `/` menu): clean-architecture, effective-java, mysql-optimization
