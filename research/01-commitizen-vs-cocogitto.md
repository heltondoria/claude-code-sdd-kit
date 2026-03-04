# Pesquisa: Commitizen vs Cocogitto

Data: 2026-03-03

## 1. Commitizen (Python)

**Fonte**: [Documentacao](https://commitizen-tools.github.io/commitizen/) | [GitHub](https://github.com/commitizen-tools/commitizen)

### Como funciona

CLI Python que forca conventional commits, automatiza bump de versao SemVer e gera changelogs. Instalado via `pip`, `pipx` ou `uv`. Configurado em `pyproject.toml` (sob `[tool.commitizen]`), `.cz.toml` ou `.cz.json`.

### Comandos principais

- **`cz commit`** -- Prompt interativo para commit convencional. Previne typos, garante formato.
- **`cz bump`** -- Analisa commits desde a ultima tag, determina incremento SemVer (MAJOR/MINOR/PATCH), atualiza versao nos arquivos configurados, cria tag git, e opcionalmente gera changelog. Prioridade: MAJOR > MINOR > PATCH.
- **`cz changelog`** -- Gera/atualiza `CHANGELOG.md` no formato Keep a Changelog por padrao. Suporta `--dry-run`, `--start-rev`, templates Jinja2, e formatos Textile, AsciiDoc, ReStructuredText.
- **`cz check`** -- Valida mensagem de commit. Usado standalone ou como hook.

### Integracao com pre-commit

```yaml
# .pre-commit-config.yaml
- repo: https://github.com/commitizen-tools/commitizen
  rev: 'v3.27.0'
  hooks:
    - id: commitizen          # commit-msg: valida formato
    - id: commitizen-branch   # pre-push: valida nome do branch
      stages: [pre-push]
```

### Customizacao

- **Plugin system**: Entry points Python. Cada plugin implementa `BaseCommitizen`.
- **`bump_pattern` / `bump_map`**: Regex + mapeamento para quais tipos de commit trigam qual incremento SemVer.
- **`message_template`**: Templates Jinja2 para formatacao de commit.
- **`version_provider`**: `commitizen`, `pep621`, `poetry`, `cargo`, `npm`, `scm`.
- **`version_scheme`**: PEP 440 (padrao) ou `"semver"` estrito.
- **`version_files`**: Array de arquivos para atualizar no bump (e.g., `["src/__init__.py:__version__"]`).
- **Changelog templates**: Jinja2 com `template`, `template_loader`, `template_extras`.

### Monorepo

Suporte **basico** via `version_files` para atualizar multiplos pacotes simultaneamente. **Nao** suporta nativamente versionamento independente por pacote. Workaround: rodar commitizen com configs diferentes por pacote.

### Determinacao de bump

1. Coleta commits desde ultima tag.
2. Processa cada commit contra `bump_pattern` regex.
3. Mapeia keywords para tipo de incremento via `bump_map`.
4. Maior prioridade encontrada vence (MAJOR > MINOR > PATCH).
5. Default: `feat` -> MINOR, `fix` -> PATCH, `BREAKING CHANGE` ou `!` -> MAJOR.
6. Flag `--major-version-zero`: previne MAJOR enquanto versao 0.x.x.

### Exemplo de configuracao

```toml
[tool.commitizen]
name = "cz_conventional_commits"
version = "1.2.3"
version_scheme = "semver"
version_provider = "pep621"
version_files = [
    "src/mypackage/__init__.py:__version__",
]
tag_format = "v$version"
update_changelog_on_bump = true
changelog_file = "CHANGELOG.md"
```

---

## 2. Cocogitto (Rust)

**Fonte**: [Documentacao](https://docs.cocogitto.io/) | [GitHub](https://github.com/cocogitto/cocogitto)

### Como funciona

Binario Rust standalone (unica dependencia: libgit2). Nao substitui git -- fornece features sobre Conventional Commits e SemVer. Config via `cog.toml`.

### Comandos principais

- **`cog commit` / `cog co`** -- Commit convencional menos verboso que `git commit`. Type autocompletion.
- **`cog bump`** -- Determina versao, cria tag, gera changelog, executa hooks pre/post. `--auto`, `--major`, `--minor`, `--patch`, `--pre <label>`.
- **`cog changelog`** -- Templates Tera (Rust). Templates built-in + customizaveis. Remote linking (GitHub, GitLab, Bitbucket).
- **`cog check`** -- Valida todos os commits no historico.
- **`cog verify --file <path>`** -- Valida um unico commit (git hooks).

### Hooks proprios

```toml
# cog.toml
[git_hooks.commit-msg]
script = """#!/bin/sh
cog verify --file $1
"""

[git_hooks.pre-push]
script = """#!/bin/sh
cog check
"""
```

**Nao** integra com pre-commit Python framework.

### Monorepo (First-Class)

```toml
[packages.my-api]
path = "packages/api"
changelog_path = "packages/api/CHANGELOG.md"
public_api = true
bump_order = 1

[packages.my-lib]
path = "packages/lib"
changelog_path = "packages/lib/CHANGELOG.md"
public_api = true
bump_order = 2
```

Features:
- Versionamento independente por pacote
- Changelogs separados por pacote
- `bump_order`: ordem de bump
- `include` / `ignore`: filtro de paths
- `pre_package_bump_hooks` / `post_package_bump_hooks`
- `cog bump --package <name>`

### Hook system

```toml
pre_bump_hooks = [
    "cargo test",
    "cargo build --release",
]
post_bump_hooks = [
    "git push",
    "git push origin {{version}}",
]
```

### Performance

Binario compilado = significativamente mais rapido que Commitizen para repos grandes. Sem overhead de Python runtime.

---

## 3. Conventional Commits v1.0.0

**Fonte**: [Especificacao](https://www.conventionalcommits.org/en/v1.0.0/)

### Estrutura

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Regras essenciais

1. Prefixo de tipo obrigatorio (`feat`, `fix`, etc.) + `:` + espaco.
2. `feat` = nova funcionalidade. `fix` = correcao de bug.
3. Scope opcional em parenteses: `feat(parser): ...`
4. Breaking changes: footer `BREAKING CHANGE:` OU `!` apos tipo/scope.
5. Outros tipos permitidos: `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.

### Mapeamento SemVer

| Commit | Incremento | Exemplo |
|--------|-----------|---------|
| `fix(scope): ...` | PATCH (x.y.**Z**) | `fix(auth): handle expired tokens` |
| `feat(scope): ...` | MINOR (x.**Y**.0) | `feat(api): add user search endpoint` |
| `BREAKING CHANGE:` / `feat!:` | MAJOR (**X**.0.0) | `feat!: remove deprecated API` |
| `docs:`, `refactor:`, `test:` | Nenhum | `docs: update README` |

### Scopes para rastreabilidade SDD

```
feat(F6): generate feature spec for task export
fix(F6): correct token refresh logic
feat(F7): add scope management
refactor(F6): extract auth middleware
```

Permite: filtrar changelogs por feature ID, vincular commits a PRD, per-feature changelog, matrizes de rastreabilidade automaticas.

---

## 4. Keep a Changelog v1.1.0

**Fonte**: [Especificacao](https://keepachangelog.com/en/1.1.0/)

### Principios

- Changelogs sao para **humanos**, nao maquinas.
- Uma entrada por **cada versao**.
- Mesmos tipos de mudanca **agrupados**.
- Versao mais recente **primeiro**.
- Data de release exibida.

### Formato

```markdown
# Changelog

## [Unreleased]

### Added
- Nova feature

## [1.1.0] - 2024-03-15

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

[Unreleased]: https://github.com/user/repo/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/user/repo/compare/v1.0.0...v1.1.0
```

### Mapeamento para Conventional Commits

| Categoria | Conventional Commit |
|-----------|-------------------|
| **Added** | `feat:` |
| **Changed** | `refactor:`, `perf:` |
| **Deprecated** | (manual ou tipo custom) |
| **Removed** | `BREAKING CHANGE` (remocao) |
| **Fixed** | `fix:` |
| **Security** | `fix:` com scope security |

### Integracao

- **Commitizen**: Gera Keep a Changelog **por padrao**.
- **Cocogitto**: Formato proprio por padrao; requer template Tera custom para Keep a Changelog.

---

## 5. Comparacao Lado a Lado

| Feature | Commitizen | Cocogitto |
|---------|-----------|-----------|
| Linguagem | Python | Rust |
| Config | `pyproject.toml`, `.cz.toml` | `cog.toml` |
| Commit interativo | `cz commit` | `cog commit` |
| Bump | `cz bump` | `cog bump` |
| Changelog | Jinja2 (Keep a Changelog padrao) | Tera (formato proprio padrao) |
| Validacao | `cz check` + pre-commit | `cog check` / `cog verify` |
| Pre-commit framework | Nativo | Nao suportado |
| Monorepo | Basico | **First-class** |
| Plugin system | Sim (Python entry points) | Nao |
| Version schemes | PEP 440 + SemVer | SemVer only |
| Performance | Moderada | Rapida |
| Git integration | Shell out | libgit2 nativo |

---

## 6. Recomendacao

### Para Python-first: **Commitizen**

- Mesmo ecossistema (`pyproject.toml`, `uv`, `pre-commit`)
- `version_provider = "pep621"` le/escreve direto no `[project].version`
- PEP 440 (padrao oficial Python)
- Keep a Changelog por padrao
- Extensivel via plugins Python

### Para monorepo com versionamento independente: **Cocogitto**

- `[packages]` nativo com versionamento por pacote
- Changelogs, tags e hooks por pacote
- Mais rapido para repos grandes

### Coexistencia

Podem coexistir (ambos leem git history) mas pouco valor pratico. Padrao recomendado: Commitizen para projetos Python, Cocogitto para monorepos poliglotas.
