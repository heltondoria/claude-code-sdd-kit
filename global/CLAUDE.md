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

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
type(scope): short description

type: feat, fix, refactor, test, docs, chore
scope: feature ID (F1, F6), discovery, prd, scaffold, adopt, or module name
```

See **Auto-Commit Convention** below for pipeline-specific commit format.

## Auto-Commit Convention

Before executing any skill, ensure the workspace is a git repository.
If not, initialize one (`git init`) and create an initial commit with existing files.

After any skill that creates or modifies files in the workspace, create a git commit
following the Conventional Commits format below. Do NOT commit if the skill only
produced console output (reviews, quality gates).

### Commit Format for Pipeline Artifacts

| Skill | Type | Scope | Example |
|-------|------|-------|---------|
| `/discovery` | `docs` | `discovery` | `docs(discovery): create discovery for project-name` |
| `/prd` | `docs` | `prd` | `docs(prd): create PRD for project-name` |
| `/feature-spec` | `docs` | `F{n}` | `docs(F6): generate feature spec for task-export` |
| `/feature-to-tasks` | `docs` | `F{n}` | `docs(F6): generate task list for task-export` |
| `/scaffold` | `chore` | `scaffold` | `chore(scaffold): create project structure` |
| `/adopt` | `chore` | `adopt` | `chore(adopt): migrate to unified tooling standards` |
| Implementation | `feat` | `F{n}` | `feat(F6): implement task export service` |
| Tests | `test` | `F{n}` | `test(F6): add task export service tests` |
| Fixes | `fix` | `F{n}` | `fix(F6): correct export encoding` |
| Refactoring | `refactor` | `F{n}` | `refactor(F6): extract export strategy` |
| Spec revision | `docs` | `F{n}` | `docs(F6): revise feature spec after review findings` |

This convention enables full traceability: `git log --grep="F6"` shows the complete
lifecycle of a feature from spec to implementation to fixes.

## Metrics

Run `python ~/.claude/scripts/sdd-metrics.py` to extract pipeline metrics from git history.
Requires conventional commits with feature ID scopes (e.g., `feat(F6): ...`).

## Platform

- **VCS**: GitLab (primary), GitHub (open source)
- **CI**: GitLab CI with pipeline-components
- **CLI fallback**: `glab` for GitLab, `gh` for GitHub
- **Package manager**: `uv` (Python), `npm`/`pnpm` (TypeScript)
