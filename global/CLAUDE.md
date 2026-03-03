<!--# BEGIN SNYK GLOBAL RULE -->
---
alwaysApply: true
always_on: true
trigger: always_on
applyTo: "**"
description: Snyk Security At Inception
---

# Project security best practices

- Always run snyk_code_scan tool for new first party code that is generated in a Snyk-supported language.
- If any security issues are found based on newly introduced or modified code or dependencies, attempt to fix the issues using the results context from Snyk.
- Rescan the code after fixing the issues to ensure that the issues were fixed and that there are no newly introduced issues.
- Repeat this process until no new issues are found.
<!--# END SNYK GLOBAL RULE -->

# CLAUDE.md (Global)

This is the global CLAUDE.md for all projects. It provides baseline guidance that every project inherits.

## Development Philosophy

- **Specification-Driven Development (SDD)**: PRD first, then tasks, then TDD implementation
- **Pipeline**: `/discovery` (optional) -> `/discovery-review` -> `/prd` -> `/prd-review` -> `/feature-spec` (per feature) -> `/feature-review` -> `/feature-to-tasks` -> `/task-review` -> implement (TDD with hooks) -> `/quality-gates` -> `/impl-review`
- **Short, verifiable tasks**: Each task must be deterministic, verifiable, objective, and atomic
- **TDD**: Write tests alongside or before implementation for early feedback
- **Strict linting on every edit**: Hooks auto-lint and type-check after every file save

## Code Quality Standards

### Python
- **Linter**: ruff (35+ rules, S rules for security)
- **Formatter**: ruff format
- **Type checker**: pyright strict mode
- **Tests**: pytest + pytest-cov (100% coverage)
- **Complexity**: xenon grade A everywhere
- **Dead code**: vulture (min-confidence 80)
- **Typos**: codespell

### TypeScript
- **Linter + Formatter**: Biome v2 (strict rules)
- **Type checker**: tsc strict mode (noUncheckedIndexedAccess, exactOptionalPropertyTypes)
- **Tests**: Vitest + @vitest/coverage-v8 (90%+ coverage)
- **Dead exports**: Knip
- **Typos**: codespell

## Security Layers

1. **Instant (hooks)**: ruff S rules on every edit
2. **Quality gates**: Semgrep local scan (offline)
3. **CI**: Full SAST, dependency scan, container scan, secret detection (pipeline-components)

## Conventions

Each project should have a `CONVENTIONS.md` at its root. The convention-checker agent reads this file.

Template available at `~/.claude/templates/CONVENTIONS.md`.

## Available Skills

| Skill | Purpose |
|-------|---------|
| `/discovery` | Discover the WHY behind a project (Golden Circle) |
| `/discovery-review` | Validate discovery document completeness (6 criteria) |
| `/prd` | Create PRD through guided questioning |
| `/prd-review` | Validate PRD completeness (11 criteria) |
| `/feature-spec` | Refine a single PRD feature into detailed implementation spec |
| `/feature-review` | Validate feature spec quality (8 criteria) before task generation |
| `/feature-to-tasks` | Generate TDD-structured task list from a feature spec |
| `/task-review` | Validate task list quality and spec coverage |
| `/quality-gates` | Run all quality checks and report pass/fail |
| `/impl-review` | Validate implementation against feature spec with scoring |
| `/scaffold` | Create new project with full tooling setup |
| `/adopt` | Migrate existing project to unified tooling standards |

## Available Agents

| Agent | Purpose |
|-------|---------|
| `convention-checker` | Check code against project CONVENTIONS.md |

## Git Conventions

### Branch Naming
- `feat/description` — New features
- `fix/description` — Bug fixes
- `refactor/description` — Refactoring
- `docs/description` — Documentation

### Commit Messages
```
type(scope): short description

type: feat, fix, refactor, test, docs, chore
```

## Platform

- **VCS**: GitLab (primary), GitHub (open source)
- **CI**: GitLab CI with pipeline-components
- **CLI fallback**: `glab` for GitLab, `gh` for GitHub
- **Package manager**: `uv` (Python), `npm`/`pnpm` (TypeScript)
