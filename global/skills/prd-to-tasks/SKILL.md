---
name: prd-to-tasks
description: Generate a prioritized task list from a PRD for autonomous loop development
argument-hint: <path-to-prd> (e.g., "PRD-myproject.md")
disable-model-invocation: true
---

# PRD to Task List Generator

Generate a prioritized implementation plan from a PRD document. The output is a ralph-compatible `fix_plan.md` designed for autonomous loop execution.

## Input

PRD file path from arguments: `$ARGUMENTS`

If no argument is provided, search for `PRD-*.md` files in the workspace and ask the user which PRD to process.

## Reference Documents

Before generating tasks, read these files to understand the project context:

1. The target PRD file (provided as argument)
2. `CLAUDE.md` from workspace root — project overview and commands
3. `CONVENTIONS.md` from workspace root (if exists) — code conventions
4. `pyproject.toml` or `package.json` — to detect stack and tooling

## Stack Detection

Detect the project stack to generate appropriate quality gate commands:

- **Python**: presence of `pyproject.toml` with `[tool.ruff]` or `[tool.pyright]`
- **TypeScript**: presence of `package.json` with `biome` or `typescript` in devDependencies
- **Both**: generate tasks for both stacks

## PRD Analysis

### Step 1: Extract Features

Read the PRD and extract ALL implementable features:

1. **Core Features** section — every bullet, checkbox, or enumerated item
2. **API Surface** section — every public function, class, method documented
3. **Exception Hierarchy** — all exception classes defined
4. **Configuration Schema** — all models and fields
5. **Integration / Middleware** — any integration layers
6. **Test Strategy** — all test scenarios described

**IMPORTANT:** Exclude "Future Expansion" / "Future Considerations" sections entirely. Everything else in the PRD must be covered.

### Step 2: Derive Project Metadata

From the PRD and project files, extract:

- **Package/project name**
- **Import/module name**
- **Module structure** (from PRD layout section)
- **External dependencies** (runtime + dev)
- **Internal dependencies** (if any)

## Task Organization

Organize tasks into **phases** grouped by **priority**. Each phase targets a cohesive layer of the project.

### Task Qualities

Each task must be:

- **Deterministic** — single, unambiguous expected outcome
- **Verifiable** — can be validated by running a command (test, lint, type check)
- **Objective** — no subjective judgment required to determine pass/fail
- **Atomic** — completable in one loop iteration (one context window)

### Task Format

Use simple markdown checkboxes with inline details:

```markdown
- [ ] <Action verb> <target> in `<file>` -- <specific details of what to implement/test>
```

Each task fits on a single line (with wrapping). Include enough detail for an AI agent to execute without ambiguity: file paths, class/function names, expected behaviors, and key parameters.

### Quality Gate Tasks

At the end of each phase, add a quality gate checkpoint appropriate to the stack:

**Python (without tests):**
```
- [ ] Run quality gates: `uv run ruff check . && uv run ruff format --check . && uv run pyright src/`
```

**Python (with tests):**
```
- [ ] Run full quality gates: `uv run ruff check . && uv run ruff format --check . && uv run pyright src/ && uv run pytest --cov=src/<package> --cov-fail-under=100 && uv run xenon --max-absolute A --max-modules A --max-average A src/ && uv run vulture --min-confidence 80 src/`
```

**TypeScript (without tests):**
```
- [ ] Run quality gates: `npx biome check . && npx tsc --noEmit && npx knip`
```

**TypeScript (with tests):**
```
- [ ] Run full quality gates: `npx biome check . && npx tsc --noEmit && npx vitest run --coverage && npx knip`
```

## Output Structure

Generate the task list as a markdown file:

````markdown
# Fix Plan -- <project-name>

## High Priority

### Phase 1: Foundation (Must complete first)
- [ ] Implement <module> in `<file>` -- <classes, functions, key details>
- [ ] Implement <module> in `<file>` -- <classes, functions, key details>
- [ ] Run quality gates: `<lint + format + type check>`

### Phase 2: Configuration & Public API
- [ ] Implement <config> in `<file>` -- <models, fields>
- [ ] Update `__init__.py` or `index.ts` -- <exports, __all__>
- [ ] Run quality gates: `<lint + format + type check>`

### Phase 3: Core Tests
- [ ] Write tests for <module> in `<test_file>` -- <specific test scenarios>
- [ ] Write tests for <module> in `<test_file>` -- <specific test scenarios>
- [ ] Run full quality gates: `<all gates>`

## Medium Priority

### Phase N: <Feature/Layer Name>
- [ ] Implement `<module>` -- <public API details>
- [ ] Write tests in `<test_file>` -- <specific test scenarios>
- [ ] Run full quality gates: `<all gates>`

## Low Priority

### Phase N: Integration & Edge Cases
- [ ] Write integration test in `<test_file>` -- <scenario>
- [ ] Write edge case tests -- <scenarios>

### Phase N+1: Quality & Documentation
- [ ] Create dead-code whitelist if needed
- [ ] Pass all quality gates: `<all gates>`

## Completed
(initially empty -- ralph marks items as completed)

## Notes

### Key Design Decisions
- **<decision>** -- <rationale>

### Implementation Order Rationale
1. <first> -- <why>
2. <second> -- <why>
````

## Phase Ordering Rules

Follow this dependency order when assigning phases:

**High Priority (must complete first):**
1. **Foundation** — exceptions, core models, main modules. Implementation only, no tests. Quality gate: lint + format + type check.
2. **Configuration & Public API** — config models, exports. Quality gate: lint + format + type check.
3. **Core Tests** — unit tests for ALL foundation modules. Quality gate: full gates.

**Medium Priority (core features):**
4. **Feature layers** — each major feature as its own phase with implementation + tests together.
5. **Integration layers** — middleware, API routes, etc. Implementation + tests.

**Low Priority (polish):**
6. **Edge cases & integration tests** — comprehensive testing.
7. **Quality & Documentation** — dead-code whitelist, README, final gate pass.

## Task Detail Rules

### For implementation tasks:
- Name the target file explicitly
- List all public classes, functions, and their key parameters inline
- Include enough detail so the implementer knows the full public API signature

### For test tasks:
- Name the test file path explicitly
- List specific test scenarios inline (what behaviors to test)
- One task per test file — keeps each task atomic
- Test function naming convention: `test_<function>_<scenario>_<expected_result>`

## Output Location

Write the generated task list to: `.ralph/fix_plan.md` in the workspace root.

If `.ralph/` directory does not exist, create it.

If the user specifies a different output path, use that instead.

## Tone

Be precise and mechanical. Every task must be unambiguous — another developer (or an AI agent) should be able to execute each task without interpretation or judgment calls.

## Commit

Commit the generated task list:
- Type: `docs`
- Scope: `prd`
- Example: `docs(prd): generate task list for <project-name>`
