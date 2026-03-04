# claude-code-sdd-kit

Specification-Driven Development toolkit for [Claude Code](https://claude.ai/code) — skills, hooks, agents, and templates for TDD-first project workflows.

## What is this?

A curated set of Claude Code configuration files that implement a full **Specification-Driven Development (SDD)** pipeline. Copy these into your `~/.claude/` directory to get a structured workflow for turning ideas into tested, production-quality code.

The pipeline enforces: **Discovery (optional), then PRD, then spec, then tasks, then TDD implementation** — with quality gates at every step.

## Pipeline

```
/discovery (optional)  ->  /discovery-review  ->  /prd  ->  /prd-review  ->  /feature-spec  ->  /feature-review  ->  /feature-to-tasks  ->  /task-review  ->  implement  ->  /quality-gates  ->  /impl-review  ->  /release
        (WHY)                                                                 (per feature)                              (TDD RED-GREEN)                                                              (semver)
```

## Contents

### Skills (13)

| Skill | Purpose |
|-------|---------|
| `/discovery` | Discover the WHY behind a project (Golden Circle) |
| `/discovery-review` | Validate discovery document completeness (6 criteria) |
| `/prd` | Create a PRD through guided questioning |
| `/prd-review` | Validate PRD completeness (11 criteria) |
| `/feature-spec` | Refine a single PRD feature into a detailed implementation spec |
| `/feature-review` | Review feature spec against quality criteria, PRD alignment, and codebase consistency |
| `/feature-to-tasks` | Generate TDD-structured task list (RED-GREEN pairs) from a feature spec |
| `/task-review` | Validate task list quality, TDD structure, and spec coverage |
| `/quality-gates` | Run all quality checks and report pass/fail |
| `/impl-review` | Validate implementation against feature spec with scoring |
| `/release` | Create a semver release with version bump, changelog, and git tag |
| `/scaffold` | Create new project with full tooling setup |
| `/adopt` | Migrate existing project to unified tooling standards |

### Hooks (4)

| Hook | Trigger | Purpose |
|------|---------|---------|
| `lint-python.sh` | PostToolUse (Edit/Write) | Auto-run `ruff check` + `ruff format` on every file save |
| `typecheck-python.sh` | PostToolUse (Edit/Write) | Auto-run `pyright` on every file save |
| `lint-typescript.sh` | PostToolUse (Edit/Write) | Auto-run `biome check` on every file save |
| `block-protected-files.sh` | PreToolUse (Edit/Write) | Prevent edits to protected files |

### Agents (2)

| Agent | Purpose |
|-------|---------|
| `convention-checker` | Check code against project `CONVENTIONS.md` rules |
| `security-bug-reviewer` | Detect security vulnerabilities and bug patterns with CWE-specialized analysis |

### Scripts (1)

| Script | Purpose |
|--------|---------|
| `sdd-metrics.py` | Extract pipeline metrics from git history (conventional commits with feature ID scopes) |

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

```bash
git clone https://github.com/heltonmc/claude-code-sdd-kit.git
cd claude-code-sdd-kit
bash install.sh
```

The script automatically backs up your existing `~/.claude/` (if any), copies all components, and prints a summary of what was installed.

To update, just `git pull && bash install.sh`.

> **Windows**: run the script inside WSL or Git Bash. Claude Code requires a Unix-like shell, so these environments are already expected.

> **Selective install**: you can also copy individual files from `global/` manually — the script is just a convenience wrapper around `cp`.

## Pipeline Metrics

After using the SDD pipeline with conventional commits, extract metrics:

```bash
python ~/.claude/scripts/sdd-metrics.py              # Full report
python ~/.claude/scripts/sdd-metrics.py --json        # JSON output
python ~/.claude/scripts/sdd-metrics.py --feature F6  # Single feature
python ~/.claude/scripts/sdd-metrics.py --period 2026-01-01:2026-03-03
```

Requires Python 3.10+ (stdlib only, no external dependencies).

## Supported Stacks

**Python**: ruff, pyright, pytest, xenon, vulture, codespell

**TypeScript**: Biome v2, tsc strict, Vitest, Knip, codespell

## License

MIT
