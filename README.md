# claude-code-sdd-kit

Specification-Driven Development toolkit for [Claude Code](https://claude.ai/code) — skills, hooks, agents, and templates for TDD-first project workflows.

## What is this?

A curated set of Claude Code configuration files that implement a full **Specification-Driven Development (SDD)** pipeline. Copy these into your `~/.claude/` directory to get a structured workflow for turning ideas into tested, production-quality code.

The pipeline enforces: **PRD first, then spec, then tasks, then TDD implementation** — with quality gates at every step.

## Pipeline

```
/prd  ->  /prd-review  ->  /feature-spec  ->  /feature-to-tasks  ->  /task-review  ->  implement  ->  /quality-gates  ->  /impl-review
                                (per feature)                           (TDD RED-GREEN)
```

There's also a legacy whole-PRD flow for simpler projects:

```
/prd  ->  /prd-review  ->  /prd-to-tasks  ->  /task-review  ->  implement  ->  /quality-gates  ->  /impl-review
```

## Contents

### Skills (10)

| Skill | Purpose |
|-------|---------|
| `/prd` | Create a PRD through guided questioning |
| `/prd-review` | Validate PRD completeness (11 criteria) |
| `/feature-spec` | Refine a single PRD feature into a detailed implementation spec |
| `/feature-to-tasks` | Generate TDD-structured task list (RED-GREEN pairs) from a feature spec |
| `/prd-to-tasks` | Generate task list from whole PRD (legacy flow) |
| `/task-review` | Validate task list quality, TDD structure, and spec/PRD coverage |
| `/quality-gates` | Run all quality checks and report pass/fail |
| `/impl-review` | Validate implementation against PRD with scoring |
| `/scaffold` | Create new project with full tooling setup |
| `/adopt` | Migrate existing project to unified tooling standards |

### Hooks (4)

| Hook | Trigger | Purpose |
|------|---------|---------|
| `lint-python.sh` | PostToolUse (Edit/Write) | Auto-run `ruff check` + `ruff format` on every file save |
| `typecheck-python.sh` | PostToolUse (Edit/Write) | Auto-run `pyright` on every file save |
| `lint-typescript.sh` | PostToolUse (Edit/Write) | Auto-run `biome check` on every file save |
| `block-protected-files.sh` | PreToolUse (Edit/Write) | Prevent edits to protected files |

### Agents (1)

| Agent | Purpose |
|-------|---------|
| `convention-checker` | Check code against project `CONVENTIONS.md` rules |

### Templates (7)

| Template | Purpose |
|----------|---------|
| `CLAUDE-project.md` | Project-level CLAUDE.md starter |
| `CONVENTIONS.md` | Code conventions template (Python + TypeScript rules) |
| `pyproject-python.toml` | Python project config (ruff, pyright, pytest, xenon, vulture) |
| `tsconfig-strict.json` | Strict TypeScript config |
| `biome.json` | Biome v2 linter/formatter config |
| `claude-settings.json` | Claude Code project settings |
| `gitlab-ci-snippets.md` | CI/CD pipeline component snippets |

## Installation

Copy the `global/` contents into your Claude Code config directory:

```bash
# Back up existing config
cp -r ~/.claude ~/.claude.bak

# Copy everything
cp global/CLAUDE.md ~/.claude/CLAUDE.md
cp global/settings.json ~/.claude/settings.json
cp -r global/skills/* ~/.claude/skills/
cp -r global/hooks/* ~/.claude/hooks/
cp -r global/agents/* ~/.claude/agents/
cp -r global/templates/* ~/.claude/templates/
```

Or selectively pick the pieces you need.

## Supported Stacks

**Python**: ruff, pyright, pytest, xenon, vulture, codespell

**TypeScript**: Biome v2, tsc strict, Vitest, Knip, codespell

## License

MIT
