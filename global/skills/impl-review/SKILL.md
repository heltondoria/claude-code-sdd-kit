---
name: impl-review
description: Validate a project implementation against its PRD and produce an adherence report with scoring
argument-hint: <impl-path> <prd-path> (e.g., "src/ PRD-myproject.md")
disable-model-invocation: true
---

# Implementation Review

Validate that a project implementation correctly covers all features defined in its PRD. Produces an adherence report with justified conclusions for each feature.

## Input

Arguments from command: `$ARGUMENTS`

Expected format: `<implementation-folder> <prd-file-path>`

Examples:
- `src/ PRD-myproject.md`
- `. PRD-myproject.md` (current directory)
- `/absolute/path/to/project PRD-myproject.md`

If no arguments are provided or incomplete, ask the user for both paths.

## Reference Documents

Before reviewing, read:

1. `CLAUDE.md` from workspace root — project overview and architecture
2. `CONVENTIONS.md` from workspace root (if exists) — code conventions

## Review Process

### Phase 1: PRD Feature Extraction

Read the PRD file and extract a **complete feature inventory**:

#### 1.1 Core Features
- Every bullet or checkbox in the Core Features section
- Capture the feature name and expected behavior

#### 1.2 Public API Surface
- Every public function, class, and method documented
- Capture: name, signature (parameters + return type), module location

#### 1.3 Exception Hierarchy
- Base exception class name and all sub-exceptions

#### 1.4 Configuration Schema
- All model class names, fields with types, defaults, and constraints

#### 1.5 Error Handling
- Which operations have defined error scenarios
- Expected error responses/exceptions

#### 1.6 Integration Layers
- Middleware, API routes, plugins, entry points

#### 1.7 Test Scenarios
- All test scenarios listed in the PRD's Test Strategy section

**IMPORTANT:** Exclude "Future Expansion" / "Future Considerations" — those features are NOT expected.

### Phase 2: Implementation Scan

Scan the implementation folder to build an inventory of what exists:

#### 2.1 Project Structure
- Read `pyproject.toml` or `package.json` for metadata and dependencies
- List all source files
- List all test files
- Check for type markers (`py.typed`, `tsconfig.json`)
- Check for exports (`__init__.py` with `__all__`, or `index.ts`)

#### 2.2 Source Code Analysis

For each source module, read and extract:
- All public classes, functions, constants
- Exception classes and hierarchy
- Config models and their fields
- Async vs sync signatures
- Docstring presence and style
- Import patterns

#### 2.3 Test Coverage Analysis

For each test file:
- Extract test function names
- Map tests to features by naming convention
- Check for integration tests
- Check for fixtures

#### 2.4 Configuration Analysis
- Verify tooling config matches project standards (ruff/pyright/biome/tsc)
- Coverage settings present and correct
- Dev dependencies include all quality tools

### Phase 3: Feature-by-Feature Verification

For each feature extracted from the PRD, determine status:

**IMPLEMENTED** — Fully present with correct signatures, type hints, tests, and docstrings
**PARTIAL** — Exists but incomplete (missing parameters, tests, or docstrings vs PRD)
**MISSING** — Not found in the codebase
**DIVERGENT** — Exists but contradicts the PRD (different signature, behavior, or location)

### Phase 4: Convention Compliance Check

Verify the implementation follows project conventions from `CONVENTIONS.md`:

1. **Type hints** — correct syntax per conventions
2. **Docstrings** — correct style on all public API
3. **Exceptions** — `from e` chaining in all `except` blocks
4. **Logging** — structured logging per conventions
5. **Config models** — frozen, with Field descriptions
6. **Async** — I/O operations match async requirements
7. **Imports** — correct ordering
8. **Test naming** — follows convention pattern

## Output Format

```
Implementation Review -- <project-name>
PRD Reference: <PRD filename>
========================================

Package Structure:           PASS / PARTIAL / MISSING
Public API Completeness:     PASS / PARTIAL / MISSING
Exception Hierarchy:         PASS / PARTIAL / MISSING
Configuration Schema:        PASS / PARTIAL / MISSING
Error Handling:              PASS / PARTIAL / MISSING
Test Coverage:               PASS / PARTIAL / MISSING
Convention Compliance:       PASS / PARTIAL / MISSING
Quality Gate Readiness:      PASS / PARTIAL / MISSING
----------------------------------------
Overall Adherence:           X/Y features implemented (Z%)
```

### Feature Adherence Detail

```
PRD Feature                   | Status      | Evidence / Justification
------------------------------|-------------|----------------------------------
<feature name>                | IMPLEMENTED | Found in <file>:<line>. Tests in
                              |             | <test_file>. Signature matches.
<feature name>                | PARTIAL     | Class exists but missing param
                              |             | `timeout` from PRD spec.
<feature name>                | MISSING     | No matching function found.
<feature name>                | DIVERGENT   | PRD specifies async but impl
                              |             | is sync at <file>:<line>.
```

### Convention Violations

```
1. [CATEGORY] <file>:<line> -- <description>
2. [CATEGORY] <file>:<line> -- <description>
```

### Missing Test Scenarios

```
PRD Test Scenario                    | Test File        | Status
-------------------------------------|------------------|--------
<scenario from PRD>                  | test_core.py:15  | COVERED
<scenario from PRD>                  | --               | MISSING
```

### Recommendations

For each PARTIAL, MISSING, or DIVERGENT item:
- What specifically needs to be added or changed
- The PRD section that defines the expected behavior
- A concrete code suggestion when helpful

## Scoring

Calculate adherence scores:

- **Feature adherence**: `IMPLEMENTED / total features * 100%`
- **Test scenario coverage**: `COVERED / total scenarios * 100%`
- **Convention compliance**: `clean items / total checked * 100%`
- **Overall score**: weighted average — 50% features, 30% tests, 20% conventions

```
Final Score
========================================

Feature Adherence:      85% (17/20 implemented)
Test Scenario Coverage: 90% (18/20 covered)
Convention Compliance:  95% (38/40 clean)
----------------------------------------
Overall Score:          89% (weighted)

Verdict: PARTIAL -- 3 features and 2 test scenarios need attention
```

Verdict thresholds:
- **100%**: COMPLETE — All PRD features implemented and verified
- **90-99%**: NEAR-COMPLETE — Minor gaps, ready for final polish
- **70-89%**: PARTIAL — Significant features missing
- **<70%**: INCOMPLETE — Major implementation gaps

## Tone

Be precise, evidence-based, and constructive. Every conclusion must cite specific files, line numbers, and PRD sections. The goal is an actionable gap analysis.
