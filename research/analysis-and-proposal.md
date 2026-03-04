# Análise e Proposta: Ferramental para Desenvolvimento Assistido por IA

## 1. Diagnóstico: O Que Já Existe (Disperso)

### 1.1 Inventário dos Seus Projetos

| Artefato | kaos-designer | libs (daprkit) | cost-sage | aqua |
|----------|:---:|:---:|:---:|:---:|
| CLAUDE.md com convenções | sim | sim (completo) | nao | sim (basico) |
| PostToolUse hooks (ruff+pyright) | sim | sim | nao | nao |
| PreToolUse hooks (block .env/lock) | sim | sim | nao | nao |
| Convention checker agent | sim | sim | nao | nao |
| Ruff config rigoroso (20+ rules) | nao | sim (referencia) | parcial (12 rules) | parcial |
| Pyright strict | sim | sim | standard | nao |
| Coverage 100% | sim | sim | via Makefile | nao |
| Xenon (complexidade) | nao | sim | via Makefile (radon) | nao |
| Vulture (dead code) | sim | sim | sim | nao |
| Codespell | nao | nao | sim | nao |
| Wily (maintainability) | nao | nao | sim | nao |
| Skills (prd-to-tasks, etc.) | nao | sim (5 skills) | nao | nao |
| Makefile/justfile | nao | nao | sim | nao |

### 1.2 Plugins Globais Instalados

```
ralph-loop, context7, playwright, github, pyright-lsp, typescript-lsp,
feature-dev, code-review, code-simplifier, hookify, security-guidance,
prd-creator, frontend-design, commit-commands, claude-code-setup,
gopls-lsp, jdtls-lsp, kotlin-lsp
```

### 1.3 Skill Global

- `/prd` — Criação interativa de PRDs (em `~/.claude/skills/prd/`)

### 1.4 Skills Valiosas Isoladas no daprkit-specs

Existem 5 skills excelentes presas ao repositório `daprkit-specs`:

| Skill | O que faz |
|-------|-----------|
| `prd-to-tasks` | Gera task list priorizada a partir de PRD, compatível com ralph loop |
| `spec-review` | Valida PRD contra checklist de qualidade (11 critérios) |
| `quality-gates` | Roda 6 quality gates e reporta pass/fail consolidado |
| `impl-review` | Valida implementação feature-by-feature contra PRD (com scoring) |
| `new-package` | Scaffold de novo pacote com toda a estrutura padrão |

### 1.5 Problemas Identificados

1. **Fragmentação**: Cada projeto reinventa hooks, configs e CLAUDE.md
2. **Inconsistência de rigor**: daprkit-config tem 25+ ruff rules, aqua tem ~20, cost-sage tem ~12
3. **Skills valiosas isoladas**: As 5 skills acima estão hardcoded para o ecossistema DaprKit
4. **Convention checker duplicado**: kaos-designer e libs têm cópias quase idênticas do mesmo agente
5. **Sem cobertura TypeScript**: Nenhum projeto tem configuração de qualidade para frontend
6. **Hooks idênticos copy-pasted**: O mesmo JSON de hooks em múltiplos `.claude/settings.json`
7. **Sem pipeline end-to-end**: As etapas (PRD > validação > tasks > validação > implementação > validação) existem como peças soltas

---

## 2. O Que a Comunidade Está Fazendo (2025-2026)

### 2.1 Specification-Driven Development (SDD)

Emergindo como paradigma dominante para desenvolvimento com agentes de IA.

**GitHub declarou em 2025**: "a especificação se torna a fonte de verdade e determina o que é construído". A análise de 2.500+ configs de agentes revelou que os specs mais eficazes cobrem 6 áreas: Commands, Testing, Project Structure, Code Style, Git Workflow e Boundaries.

**Workflow de 5 estágios**: spec authoring > planning > task breakdown > implementation > validation com drift detection.

**Critérios de aceite para agentes**: PRDs para agentes requerem critérios quantificados e testáveis, não subjetivos. "Deve ser intuitivo" vira "tempo de resposta < 200ms". Formato: `Given [precondição], When [ação], Then [resultado]`.

**Padrão "DO NOT CHANGE"**: Ser explícito sobre o que NÃO deve mudar ao adicionar funcionalidade (schema, API signatures, auth flow).

Fontes: [Addy Osmani — How to write a good spec](https://addyosmani.com/blog/good-spec/), [ThoughtWorks — Spec-driven development](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices), [Haberlah — PRDs for AI Coding Agents](https://medium.com/@haberlah/how-to-write-prds-for-ai-coding-agents-d60d72efb797)

### 2.2 Anthropic 2026 Agentic Coding Trends Report

8 tendências identificadas a partir de dados reais de uso:

1. **Desenvolvedores como orquestradores** — 60% do trabalho usa IA, mas só 0-20% é totalmente delegado
2. **Multi-agent com context windows especializados** — agentes paralelos em contextos isolados
3. **~20 ações autônomas** antes de requerer input humano (dobro do ano anterior)
4. **Expansão para além de engenharia** — Zapier: 97% de adoção de IA em toda a organização
5. **Agentic coding em novas superfícies** — docs, data pipelines, infra
6. **30-79% de compressão de timelines** — Rakuten: 24 dias para 5 dias
7. **Code design/planning** subiu de 1% para 10% do uso de IA
8. **Security-first como requisito não-negociável** — embeddado desde o design, não retrofitted

Fonte: [Anthropic — 2026 Agentic Coding Trends Report](https://resources.anthropic.com/2026-agentic-coding-trends-report), [Sola Fide — 8 Trends Summary](https://solafide.ca/blog/anthropic-2026-agentic-coding-trends-reshaping-software-development)

### 2.3 Loop Development e Gestão de Contexto

**Addy Osmani — LLM Coding Workflow 2026**:
- Loops iterativos pequenos reduzem erros catastróficos drasticamente
- "Prompt plan" estruturado: arquivo com sequência de prompts por tarefa
- TDD como feedback loop natural para agentes
- "LLMs são tão bons quanto o contexto que você fornece"
- Anti-pattern documentado: "building, building, building" sem parar gera "inconsistent mess"

**Kovyrin — PRD-Tasklist Process**:
- 20-30 min brain-dump > PRD iterativo com modelo grande
- Task list como "documento vivo, não contrato rígido"
- Per-task: git clean > fresh context > execute > reflect > commit
- Reflexão mid-execution captura surpresas e decisões para próximas sessions
- Escopo ideal: 2+ horas de trabalho, não mais que ~2 semanas por ciclo

**Ralph Loop**: Plugin oficial da Anthropic. Stop hook que intercepta saída do Claude e re-alimenta o prompt. Ideal quando há verificação automática (tests, linter, build). Usa `fix_plan.md` como source of truth.

Fontes: [Addy Osmani — My LLM coding workflow 2026](https://addyosmani.com/blog/ai-coding-workflow/), [Kovyrin — PRD-Driven AI Agents](https://kovyrin.net/2025/06/20/prd-tasklist-process/), [Ralph Loop Plugin](https://claude.com/plugins/ralph-loop), [AI Dev Tasks Framework](https://johnoct.github.io/blog/2025/07/24/ai-dev-tasks-framework/)

### 2.4 Tooling Convergente

**Python Backend**:
- **ruff** como linter+formatter unificado (substitui flake8, isort, black, pylint parcialmente)
- **pyright strict** ou **basedpyright** para type checking
- **xenon** para gate de complexidade ciclomática (grade A)
- **vulture** para dead code detection
- **pytest + pytest-cov** com 100% coverage
- **codespell** para typos em código e docs
- **uv** como package manager (padrão emergente)

**TypeScript Frontend**:
- **Biome v2** (jun/2025): type-aware linting sem depender do compilador TypeScript, 10-25x mais rápido que ESLint+Prettier, config unificada
- **ESLint + typescript-eslint** strict + stylistic: máximo rigor mas mais lento (~7min em cold run de monorepo)
- **TypeScript strict mode** com flags adicionais (`noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`)

**Claude Code — Boas Práticas**:
- PostToolUse hooks para lint automático a cada edit — feedback imediato
- PreToolUse hooks para bloquear operações destrutivas
- Manter < 10 MCP servers e < 80 tools (context window é finito — muitos MCPs reduzem de ~200k para ~70k tokens úteis)
- Skills ativam automaticamente por match de descrição
- Para hooks complexos, usar scripts externos em vez de one-liners inline

Fontes: [Biome v2](https://biomejs.dev/blog/biome-v2/), [PyStrict template](https://github.com/Ranteck/PyStrict-strict-python), [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide), [Claude Code Full Stack](https://alexop.dev/posts/understanding-claude-code-full-stack/), [Best MCP Servers 2026](https://www.builder.io/blog/best-mcp-servers-2026)

---

## 3. Proposta: Ferramental Unificado

### 3.1 Arquitetura

```
~/.claude/                              GLOBAL (vale para TODOS os projetos)
  CLAUDE.md                             Regras universais (Snyk + convenções base)
  settings.json                         Plugins habilitados
  skills/
    prd/SKILL.md                        Criação de PRD (já existe)
    prd-review/SKILL.md                 Validação de PRD (generalizar spec-review)
    prd-to-tasks/SKILL.md              PRD > task list (generalizar)
    task-review/SKILL.md                Validação de task list vs PRD (novo)
    impl-review/SKILL.md               Validação de implementação vs PRD (generalizar)
    quality-gates/SKILL.md             Rodar quality gates (generalizar)
    scaffold/SKILL.md                   Scaffold de novo projeto (generalizar new-package)
  agents/
    convention-checker.md               Agente genérico que lê CONVENTIONS.md local
  hooks/
    lint-python.sh                      ruff check --fix + format
    typecheck-python.sh                 pyright
    lint-typescript.sh                  biome ou eslint (auto-detect)
    block-protected-files.sh            Bloqueia .env, lockfiles
  templates/
    CONVENTIONS.md                      Template default de convenções
    pyproject-python.toml               Config "golden" para Python
    biome.json                          Config "golden" para TypeScript
    tsconfig-strict.json                TypeScript strict
    claude-settings.json                .claude/settings.json template para projetos
    CLAUDE-project.md                   Template de CLAUDE.md para projetos

<project>/                              POR PROJETO
  CLAUDE.md                             Contexto específico do projeto
  CONVENTIONS.md                        Regras de convenção (customizável, herda do template)
  .claude/
    settings.json                       Hooks (referencia scripts globais)
  docs/
    PRD-<name>.md                       Product Requirements Document
    TASKS-<name>.md                     Task list derivada do PRD
  pyproject.toml / biome.json           Configs de tooling do projeto
```

### 3.2 Pipeline End-to-End

```
SPECIFICATION PHASE
===================

/prd --------> PRD-<name>.md --------> /prd-review --------> PASS?
(criar)        (documento)              (validar)              |
                                                          NO --+-> corrigir e re-validar
                                                          YES
                                                           |
/prd-to-tasks -> TASKS-<name>.md -> /task-review -------> PASS?
(decompor)       (task list)         (validar)              |
                                                       NO --+-> corrigir e re-validar
                                                       YES
                                                        |
IMPLEMENTATION PHASE                                    v
====================

Para cada task (manual ou via /ralph-loop):

  1. git status limpo (possibilitar rollback)
  2. contexto fresco (evitar corrupção acumulada)
  3. implementar com TDD:
     a. escrever test primeiro (red)
     b. implementar (green)
     c. refactor
  4. hooks disparam automaticamente:
     - PostToolUse: ruff fix + format + pyright (Python)
     - PostToolUse: biome check --fix (TypeScript)
  5. testes passam? -> se não, corrigir e repetir
  6. /quality-gates -> se FAIL, corrigir e repetir
  7. commit + marcar task como concluída
  8. reflect: atualizar discoveries/notas no task file
  9. próxima task

VALIDATION PHASE
================

/impl-review -----> Adherence report -----> PASS?
(PRD vs código)     (feature-by-feature)      |
                    (com scoring)         NO --+-> corrigir gaps
                                          YES
                                           |
                                         DONE
```

### 3.3 Convention Checker: Agente Global com Regras Locais

**Princípio**: A mecânica de revisão (como buscar, como reportar, severidades) é fixa e global. As regras específicas vivem num arquivo local do projeto.

```
~/.claude/agents/convention-checker.md    Lógica fixa (global)
    lê
    |
<project>/CONVENTIONS.md                  Regras específicas (local)
    fallback
    |
~/.claude/templates/CONVENTIONS.md        Template default com regras padrão
```

**Fluxo do agente**:
1. Busca `CONVENTIONS.md` na raiz do workspace
2. Se não existir, usa defaults sensatos para a stack detectada (Python/TypeScript)
3. Identifica arquivos alterados
4. Verifica contra as regras carregadas
5. Reporta apenas violações genuínas com file:line, regra violada e fix concreto

**Template de CONVENTIONS.md** (projeto só customiza o que precisa):

```markdown
# Project Conventions

## Stack
- backend: python 3.12+
- frontend: typescript (react)

## Python Rules

### Async I/O
- required: true
- asyncio_to_thread: allowed with warning

### Type Hints
- public-api: required
- syntax: modern (list[T], X | None — never List[T], Optional[X])
- typing-deprecated-imports: error

### Exceptions
- base-exception: <ProjectName>Error(Exception)
- chaining: required (raise ... from e)
- bare-except: error

### Logging
- style: structured (extra={})
- f-strings-in-messages: error
- pattern: logger.info("event_name", extra={"key": value})

### Testing
- naming: test_<function>_<scenario>_<expected_result>
- async: pytest.mark.asyncio or asyncio_mode=auto

### Config Models
- base: Pydantic v2
- frozen: true
- fields: Field() with descriptions

### Docstrings
- style: google
- public-api: required
- severity: info (only flag when asked)

## TypeScript Rules

### Type Safety
- explicit-any: error
- non-null-assertion: error
- null-handling: explicit

### Error Handling
- bare-catch: error
- error-types: typed

### Logging
- console-log: error (use logger)

### Immutability
- prefer-const: true
- prefer-readonly: true

## Security
- hardcoded-secrets: error
- unsafe-yaml: error
- eval-or-exec: error
- unsafe-inner-html: error

## Custom Rules
<!-- Adicione regras específicas do projeto aqui -->
```

### 3.4 Hooks Unificados

Scripts globais em `~/.claude/hooks/`, referenciados por qualquer projeto.

#### lint-python.sh

```bash
#!/bin/bash
filepath="$CLAUDE_FILE_PATH"
[[ "$filepath" != *.py ]] && exit 0

dir=$(dirname "$filepath")
while [ "$dir" != "/" ] && [ ! -f "$dir/pyproject.toml" ]; do
    dir=$(dirname "$dir")
done
[ ! -f "$dir/pyproject.toml" ] && exit 0

cd "$dir"
uv run ruff check --fix "$filepath" 2>/dev/null
uv run ruff format "$filepath" 2>/dev/null
```

#### typecheck-python.sh

```bash
#!/bin/bash
filepath="$CLAUDE_FILE_PATH"
[[ "$filepath" != *.py ]] && exit 0

dir=$(dirname "$filepath")
while [ "$dir" != "/" ] && [ ! -f "$dir/pyproject.toml" ]; do
    dir=$(dirname "$dir")
done
[ ! -f "$dir/pyproject.toml" ] && exit 0

cd "$dir" && uv run pyright "$filepath" 2>/dev/null
```

#### lint-typescript.sh

```bash
#!/bin/bash
filepath="$CLAUDE_FILE_PATH"
[[ "$filepath" != *.ts && "$filepath" != *.tsx && "$filepath" != *.js && "$filepath" != *.jsx ]] && exit 0

dir=$(dirname "$filepath")
while [ "$dir" != "/" ] && [ ! -f "$dir/package.json" ]; do
    dir=$(dirname "$dir")
done
[ ! -f "$dir/package.json" ] && exit 0

cd "$dir"
if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
    npx biome check --fix "$filepath" 2>/dev/null
elif [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ] || [ -f ".eslintrc.json" ]; then
    npx eslint --fix "$filepath" 2>/dev/null
fi
```

#### block-protected-files.sh

```bash
#!/bin/bash
filepath="$CLAUDE_FILE_PATH"
if echo "$filepath" | grep -qE '(\.(env|lock)$|uv\.lock|pnpm-lock\.yaml|package-lock\.json|yarn\.lock)$'; then
    echo "BLOCKED: Do not edit lock files or .env files directly." >&2
    exit 2
fi
```

#### .claude/settings.json (Template para Projetos)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/lint-python.sh", "timeout": 15000 },
          { "type": "command", "command": "~/.claude/hooks/typecheck-python.sh", "timeout": 30000 },
          { "type": "command", "command": "~/.claude/hooks/lint-typescript.sh", "timeout": 15000 }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/block-protected-files.sh", "timeout": 5000 }
        ]
      }
    ]
  }
}
```

Cada hook verifica a extensão do arquivo internamente, então hooks de Python são no-ops silenciosos em projetos TypeScript e vice-versa. Um único settings.json funciona para qualquer stack.

### 3.5 Skills Globais (Generalizadas)

Baseadas nas 5 skills do daprkit-specs, removendo hardcoding de ecossistema:

| Skill | Base Original | Mudanças |
|-------|-----------|---------|
| `/prd` | Já global | Manter como está |
| `/prd-review` | daprkit-specs/spec-review | Remover refs DaprKit, checklist genérico por stack, ler CONVENTIONS.md do projeto |
| `/prd-to-tasks` | daprkit-specs/prd-to-tasks | Remover refs DaprKit, suportar Python e TypeScript, ler quality gates do pyproject.toml/biome.json |
| `/task-review` | Novo | Validar task list vs PRD: completude, atomicidade, verificabilidade, cobertura de features |
| `/impl-review` | daprkit-specs/impl-review | Remover refs DaprKit, aceitar qualquer stack, scoring genérico |
| `/quality-gates` | daprkit-specs/quality-gates | Auto-detect stack, rodar gates Python (ruff, pyright, pytest-cov, xenon, vulture) e/ou TypeScript (biome/eslint, tsc, vitest/jest) conforme o projeto |
| `/scaffold` | daprkit-specs/new-package | Generalizar para qualquer projeto Python ou TypeScript, aplicar templates golden |

### 3.6 Configuração de Linters — Referência "Golden"

#### Python: Ruff (Máximo Rigor)

```toml
[tool.ruff]
target-version = "py312"  # ajustar por projeto
line-length = 88
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # pyflakes
    "I",      # isort
    "N",      # pep8-naming
    "UP",     # pyupgrade
    "S",      # flake8-bandit (security)
    "B",      # flake8-bugbear
    "A",      # flake8-builtins
    "BLE",    # flake8-blind-except
    "C4",     # flake8-comprehensions
    "PT",     # flake8-pytest-style
    "ANN",    # flake8-annotations
    "ARG",    # flake8-unused-arguments
    "T20",    # flake8-print (force logging)
    "RET",    # flake8-return
    "SLF",    # flake8-self (private member access)
    "SIM",    # flake8-simplify
    "TCH",    # flake8-type-checking
    "PIE",    # flake8-pie
    "PTH",    # flake8-use-pathlib
    "ERA",    # eradicate (commented-out code)
    "ASYNC",  # flake8-async
    "PLC",    # pylint convention
    "PLE",    # pylint error
    "PLR",    # pylint refactor
    "PLW",    # pylint warning
    "RUF",    # ruff-specific
    "PERF",   # perflint (performance anti-patterns)
    "FBT",    # flake8-boolean-trap
    "DTZ",    # flake8-datetimez
    "ICN",    # flake8-import-conventions
    "ISC",    # flake8-implicit-str-concat
    "TID",    # flake8-tidy-imports
    "FLY",    # flynt (f-string conversion)
    "TRY",    # tryceratops (exception patterns)
]
ignore = [
    "PLR0913",  # too many arguments (common in DI-heavy code)
    "PLR2004",  # magic value comparison (noisy in tests)
    "ANN401",   # disallow Any (sometimes unavoidable)
    "TRY003",   # long exception messages (acceptable)
    "ISC001",   # conflicts with ruff formatter
]

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = [
    "S101",     # allow assert
    "S105",     # allow hardcoded passwords in test fixtures
    "ARG001",   # allow unused args (fixtures)
    "ANN",      # skip annotations in tests
    "SLF001",   # allow private access in tests
    "PLC0415",  # allow non-top-level imports
    "PT012",    # allow complex pytest.raises blocks
    "BLE001",   # allow blind except in tests
    "FBT",      # allow boolean args in tests
]

[tool.ruff.lint.isort]
known-first-party = ["<package_name>"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

#### Python: Pyright Strict

```toml
[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.12"
```

#### Python: Pytest + Coverage + Quality Tools

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = ["-v", "--strict-markers", "--tb=short"]
markers = [
    "integration: marks tests as integration tests",
    "slow: marks tests as slow",
]

[tool.coverage.run]
source = ["src/<package_name>"]
branch = true

[tool.coverage.report]
fail_under = 100
show_missing = true
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "if __name__ == .__main__.",
    "@overload",
    "\\.\\.\\.",
    "@abstractmethod",
    "raise NotImplementedError",
]

[tool.vulture]
min_confidence = 80
paths = ["src/<package_name>"]

[tool.codespell]
skip = ".git,.venv,uv.lock"
check-filenames = true
```

#### Python: Dev Dependencies Padrão

```toml
[dependency-groups]
dev = [
    "pytest>=9.0",
    "pytest-asyncio>=1.3",
    "pytest-cov>=7.0",
    "pyright>=1.1",
    "ruff>=0.15",
    "xenon>=0.9",
    "vulture>=2.14",
    "codespell>=2.4",
]
```

#### TypeScript: Biome (Recomendado para Novos Projetos)

```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noExcessiveCognitiveComplexity": {
          "level": "error",
          "options": { "maxAllowedComplexity": 10 }
        }
      },
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "error"
      },
      "security": {
        "noDangerouslySetInnerHtml": "error"
      },
      "suspicious": {
        "noExplicitAny": "error",
        "noConsole": "warn"
      },
      "style": {
        "noNonNullAssertion": "error",
        "useConst": "error",
        "useNodejsImportProtocol": "error"
      },
      "performance": {
        "noAccumulatingSpread": "error"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  }
}
```

#### TypeScript: tsconfig.json Strict

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "exactOptionalPropertyTypes": true,
    "verbatimModuleSyntax": true
  }
}
```

### 3.7 Plugins Claude Code (Otimizados)

```json
{
  "enabledPlugins": {
    "ralph-loop@claude-plugins-official": true,
    "context7@claude-plugins-official": true,
    "playwright@claude-plugins-official": true,
    "github@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "commit-commands@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "hookify@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true
  }
}
```

**Removidos** (economizar contexto — cada plugin consome tokens):

| Plugin | Motivo |
|--------|--------|
| `code-simplifier` | Duplica o que `code-review` já faz |
| `frontend-design` | Muito especializado, habilitar sob demanda |
| `gopls-lsp` | Não relevante para Python/TypeScript |
| `jdtls-lsp` | Não relevante para Python/TypeScript |
| `kotlin-lsp` | Não relevante para Python/TypeScript |
| `prd-creator@local` | Substituído pelo `/prd` skill global |
| `claude-code-setup` | Uso pontual, não precisa estar sempre ativo |

### 3.8 MCP Servers

| MCP | Propósito | Prioridade |
|-----|----------|-----------|
| **context7** | Documentação up-to-date de libs | Alta |
| **playwright** | Testes E2E, browser automation | Alta (frontend) |
| **github** | Issues, code search, PRs (quando usar GH) | Média |
| **sequential-thinking** | Raciocínio estruturado para problemas complexos | Média |
| **memory** | Persistência de conhecimento entre sessões | Média |

**Nota sobre GitLab**: O MCP oficial do GitLab (experimental, GitLab 18.6+) tem um bug conhecido onde envia texto plano fora do protocolo MCP após login, quebrando o client do Claude Code. Por agora, usar `glab` CLI via Bash como fallback. O GitHub MCP continua útil para projetos open-source no GH. Revisitar o GitLab MCP quando sair de experimental.

**Atenção ao budget de contexto**: Cada MCP consome tokens do context window com tool descriptions. Manter < 10 MCPs ativos. Mais MCPs podem reduzir de ~200k para ~70k tokens úteis.

### 3.9 Security: Camadas Complementares

| Camada | Ferramenta | Onde | Offline? | Latência |
|--------|-----------|------|----------|----------|
| PostToolUse hooks | ruff regras `S` (bandit) | Cada edit de .py | Sim | ~100ms |
| `/quality-gates` skill | Semgrep (local) | Sob demanda | Sim | ~5-15s |
| CI pipeline | Semgrep + Trivy + Gitleaks + Snyk | Cada push/MR | Não | ~60-120s |
| CLAUDE.md global | Regra Snyk (consciência) | Sempre em contexto | — | — |

**Por que não Snyk local**: `snyk code test` envia código para servidores Snyk (não é offline). O Snyk Code Local Engine é enterprise-only. Semgrep é open-source, offline, rápido, e já está nos pipeline-components (componente `sast-semgrep`). Consistência entre local e CI.

### 3.10 TypeScript Quality Gates

| Gate | Ferramenta | Comando |
|------|-----------|---------|
| Lint + Format | Biome v2 | `npx biome check .` |
| Type check | tsc strict | `npx tsc --noEmit` |
| Tests + Coverage | Vitest + v8 | `npx vitest run --coverage` |
| Complexidade | Biome (built-in) | `noExcessiveCognitiveComplexity` na config |
| Dead code | Knip | `npx knip` |
| Typos | codespell | `codespell .` |
| Security (CI) | Semgrep | Nos pipeline-components |

Coverage threshold: **90%** para frontend (ajustável por projeto).

### 3.11 CI: Reuso dos Pipeline Components Existentes

Os pipeline-components em `/devops/pipeline-components/` já cobrem todos os quality gates Python. Não é necessário criar templates CI do zero.

**Para Python** — usar os composed templates existentes:

```yaml
# Libs: library-python-pyright (pyright strict, lint enforced)
include:
  - component: $CI_SERVER_FQDN/luxtekna/devops/pipeline-components/templates/library-python-pyright@v1.9.0
    inputs:
      python_version: "3.12"
      coverage_threshold: 100
      enable_vulture: true

# Microserviços: microservice-python
include:
  - component: $CI_SERVER_FQDN/luxtekna/devops/pipeline-components/templates/microservice-python@v1.9.0
    inputs:
      python_version: "3.12"
      coverage_threshold: 100
      enable_pyright: true
      enable_vulture: true
```

**Para TypeScript** — trabalho futuro nos pipeline-components (Node.js/TypeScript está no roadmap do PRD).

### 3.9 Platform-Agnostic Git Workflow

As skills e CLAUDE.md usam terminologia neutra:

| Conceito | Termo usado |
|----------|------------|
| Code review request | "merge request" (com nota: "pull request no GitHub") |
| CI pipeline | "pipeline" (funciona em GitLab CI e GitHub Actions) |
| Remote hosting | Sem assumir plataforma |
| CLI commands | `git` nativo (não `gh` ou `glab` hardcoded) |

O `commit-commands` plugin do Claude Code já é git-agnostic. Para operações específicas de plataforma, o agente deve detectar o remote:

```bash
git remote get-url origin | grep -q "gitlab" && echo "gitlab" || echo "github"
```

---

## 4. Plano de Implementação

### Fase 1: Infraestrutura Global

1. Criar `~/.claude/hooks/` com os 4 scripts (lint-python, typecheck-python, lint-typescript, block-protected-files)
2. Tornar scripts executáveis (`chmod +x`)
3. Criar `~/.claude/templates/` com configs golden (CONVENTIONS.md, pyproject.toml, biome.json, tsconfig.json, claude-settings.json, CLAUDE-project.md)
4. Criar `~/.claude/agents/convention-checker.md` (agente genérico que lê CONVENTIONS.md local)
5. Atualizar `~/.claude/settings.json` (plugins otimizados)

### Fase 2: Skills Globais

6. Generalizar e instalar em `~/.claude/skills/`:
   - `/prd-review` (baseado em spec-review)
   - `/prd-to-tasks` (baseado em prd-to-tasks)
   - `/task-review` (novo)
   - `/impl-review` (baseado em impl-review)
   - `/quality-gates` (baseado em quality-gates)
   - `/scaffold` (baseado em new-package)

### Fase 3: Documentação

7. Expandir `~/.claude/CLAUDE.md` global com convenções universais e referência ao pipeline
8. Documentar o pipeline completo num README neste repo (base/)

### Fase 4: Migração Gradual

9. Aplicar CONVENTIONS.md + hooks unificados nos projetos existentes
10. Substituir hooks inline por referências aos scripts globais
11. Remover skills duplicadas do daprkit-specs (manter referência para os globais)

---

## 5. Decisões Consolidadas

| # | Questão | Decisão |
|---|---------|---------|
| 1 | Frontend linter | **Biome v2** como padrão; ESLint auto-detect via hook para projetos legados |
| 2 | Test runner TS | **Vitest** com @vitest/coverage-v8, threshold 90% |
| 3 | Dead code TS | **Knip** para exports/deps/files não usados |
| 4 | CI templates | Reusar **pipeline-components existentes** para Python; guardar snippets de include; TypeScript será trabalho futuro |
| 5 | Security local | **Semgrep** no `/quality-gates` (offline, consistente com CI); ruff `S` no hook; Snyk só no CI |
| 6 | GitLab MCP | **`glab` CLI** por agora; MCP oficial tem bug (texto plano fora do protocolo MCP); revisitar quando estável |
| 7 | Convention checker | Agente **global** que lê **`CONVENTIONS.md` local** com fallback para template default |
| 8 | Git platform | **GitLab-first**, terminologia neutra nas skills, `glab`/`gh` por detecção de remote |

---

## 6. Fontes

- [Addy Osmani — My LLM coding workflow going into 2026](https://addyosmani.com/blog/ai-coding-workflow/)
- [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/)
- [Addy Osmani — The 80% Problem in Agentic Coding](https://addyo.substack.com/p/the-80-problem-in-agentic-coding)
- [Anthropic — 2026 Agentic Coding Trends Report](https://resources.anthropic.com/2026-agentic-coding-trends-report)
- [Anthropic — 8 Trends Summary](https://solafide.ca/blog/anthropic-2026-agentic-coding-trends-reshaping-software-development)
- [Kovyrin — Align, Plan, Ship: PRD-Driven AI Agents](https://kovyrin.net/2025/06/20/prd-tasklist-process/)
- [AI Dev Tasks Framework](https://johnoct.github.io/blog/2025/07/24/ai-dev-tasks-framework/)
- [Haberlah — How to write PRDs for AI Coding Agents](https://medium.com/@haberlah/how-to-write-prds-for-ai-coding-agents-d60d72efb797)
- [ThoughtWorks — Spec-driven development 2025](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [Specification Driven Development (SDD)](https://medium.com/ai-pace/specification-driven-development-sdd-ai-first-coding-practice-e8f4cc3c2fc4)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Claude Code Full Stack: MCP, Skills, Subagents, Hooks](https://alexop.dev/posts/understanding-claude-code-full-stack/)
- [Claude Code Hooks for uv Projects](https://pydevtools.com/blog/claude-code-hooks-for-uv/)
- [How I Use Every Claude Code Feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)
- [PyStrict — Ultra-strict Python template](https://github.com/Ranteck/PyStrict-strict-python)
- [Biome v2 — Type-aware linting](https://biomejs.dev/blog/biome-v2/)
- [Best MCP Servers for Developers 2026](https://www.builder.io/blog/best-mcp-servers-2026)
- [Ralph Loop Plugin](https://claude.com/plugins/ralph-loop)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code Showcase](https://github.com/ChrisWiles/claude-code-showcase)
- [Zylos — Long-Running AI Agents and Task Decomposition](https://zylos.ai/research/2026-01-16-long-running-ai-agents)
- [McKinsey — Agentic Workflows for Software Development](https://medium.com/quantumblack/agentic-workflows-for-software-development-dc8e64f4a79d)
