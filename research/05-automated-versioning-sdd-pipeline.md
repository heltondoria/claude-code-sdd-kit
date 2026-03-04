# Pesquisa: Versionamento Automatizado no Pipeline SDD

Data: 2026-03-04

## 1. Landscape de Ferramentas

### 1.1 Comparacao Geral

| Feature | commitizen (Python) | cocogitto (Rust) | semantic-release (Node.js) | release-please (Google) | git-cliff (Rust) |
|---|---|---|---|---|---|
| **Downloads/semana** | ~60K (PyPI) | ~1K (crates.io) | **~2.2M (npm)** | ~108K (npm) | ~5K (crates.io) |
| **GitHub Stars** | ~3.3K | ~1K | **~23K** | ~6.5K | ~11.5K |
| **Commit enforcement** | Sim (pre-commit) | Sim (`cog check`) | Nao | Nao | Nao |
| **Interactive commit** | Sim (`cz commit`) | Sim (`cog commit`) | Nao | Nao | Nao |
| **Version bump** | Sim (atualiza files) | Sim (via hooks) | Sim (atualiza files) | Sim (via Release PR) | Calcula apenas |
| **pyproject.toml** | **Nativo** (pep621/uv) | Via pre-bump hook | Via plugin | **Nativo** (python type) | Nao atualiza |
| **package.json** | Via version_files/npm | Via pre-bump hook | **Nativo** | **Nativo** (node type) | Nao atualiza |
| **Changelog** | Keep a Changelog | Tera templates | Plugin-based | Built-in | **Melhor (Tera)** |
| **Release PR** | Nao | Nao | Nao | **Sim (core)** | Nao |
| **GitHub** | Funciona em CI | Funciona em CI | Nativo | **Nativo** | Nativo |
| **GitLab** | Funciona em CI | Funciona em CI | Via plugin | **NAO** | Nativo |
| **Monorepo** | Basico | **First-class** | Via plugins | Full support | Via path filters |
| **Pre-bump hooks** | Limitado | **Nativo** | Plugin-based | Nao | N/A |
| **Post-bump hooks** | Sim | **Nativo** | Plugin-based | Via GH Actions | N/A |
| **Install pip** | Sim | Nao | Nao | Nao | Sim |
| **Install npm** | Nao | Nao | Sim | Sim | Sim |
| **Install cargo** | Nao | Sim | Nao | Nao | Sim |

### 1.2 Logica de Detecao de Bump

Todas as ferramentas seguem o mesmo mapeamento semantico:

| Commit | Incremento | Exemplo |
|--------|-----------|---------|
| `fix(scope): ...` | PATCH (x.y.**Z**) | `fix(auth): handle expired tokens` |
| `feat(scope): ...` | MINOR (x.**Y**.0) | `feat(api): add user search` |
| `BREAKING CHANGE:` / `feat!:` | MAJOR (**X**.0.0) | `feat!: remove deprecated API` |
| `docs:`, `refactor:`, `test:` | Nenhum | `docs: update README` |

**Diferenca-chave no workflow**:
- **semantic-release/commitizen/cocogitto**: bump imediato ao trigger
- **release-please**: acumula commits em Release PR; bump so ocorre ao merge da PR

### 1.3 Atualizacao de Arquivos de Versao

**commitizen**: Nativo via `version_files`:
```toml
[tool.commitizen]
version_provider = "pep621"  # ou "uv" para projetos uv
version_files = [
    "src/__version__.py:__version__",
    "pyproject.toml:version",
]
```
Flag `--check-consistency` verifica que todos os arquivos tem a mesma versao.

**cocogitto**: Via hooks com template `{{version}}`:
```toml
pre_bump_hooks = [
    "sed -i 's/version = .*/version = \"{{version}}\"/' pyproject.toml",
    "npm version {{version}} --no-git-tag-version",
]
```

**release-please**: Nativo via release types (~20 linguagens suportadas). Python atualiza `pyproject.toml`, `setup.py`, `setup.cfg`, `version.py`. Node atualiza `package.json`, `package-lock.json`. Extra-files config para arquivos arbitrarios.

**git-cliff**: **Nao atualiza arquivos**. So calcula a versao (`--bumped-version`). Requer script externo.

---

## 2. Gestao de Versao Multi-linguagem

### 2.1 Desafio

Em projetos poliglotas (Python backend + TypeScript frontend), versoes vivem em arquivos diferentes (`pyproject.toml` vs `package.json`) com ferramental diferente.

### 2.2 Estrategias para Polyrepo

1. **Versionamento independente** (recomendado): Cada repo tem seu proprio ciclo de versao. Compatibilidade via API contracts (OpenAPI specs) e dependency pinning.

2. **Coordenacao via CI/CD**: Quando repo A cria release, trigger no repo B atualiza dependencias (repository dispatch, webhooks).

3. **Release trains**: Janelas periodicas de release coordenado entre repos.

4. **Dependency automation**: Renovate ou Dependabot criam PRs automaticamente quando upstream muda.

### 2.3 Suporte por Ferramenta

| Ferramenta | pyproject.toml | package.json | Ambos |
|---|---|---|---|
| commitizen | Nativo (pep621/uv) | Via version_files ou npm provider | Sim |
| cocogitto | Via hooks | Via hooks | Sim |
| semantic-release | Via plugin | Nativo | Sim (plugins) |
| release-please | Nativo (python type) | Nativo (node type) | Sim (manifest) |

---

## 3. Changelog

### 3.1 Formatos

| Formato | Filosofia | Fonte |
|---|---|---|
| **Keep a Changelog** | Para humanos, curado, categorizado | keepachangelog.com |
| **Conventional Changelog** | Gerado de commits, granular | conventional-changelog |
| **Common Changelog** | Keep a Changelog estrito + refs | common-changelog.org |

### 3.2 Mapeamento Conventional Commits -> Keep a Changelog

| Categoria KaC | Tipo de Commit |
|---|---|
| **Added** | `feat:` |
| **Changed** | `refactor:`, `perf:` |
| **Deprecated** | (manual ou tipo custom) |
| **Removed** | Breaking change (remocao) |
| **Fixed** | `fix:` |
| **Security** | `fix:` com scope security |

### 3.3 Ferramentas de Changelog

| Ferramenta | Linguagem | Velocidade | Templates | Keep a Changelog |
|---|---|---|---|---|
| **git-cliff** | Rust | **120ms** | Tera (Jinja2-like) | Sim (template) |
| conventional-changelog | Node.js | Rapido | Handlebars | Nao |
| commitizen (built-in) | Python | Rapido | Built-in | Sim (padrao) |
| cocogitto (built-in) | Rust | Rapido | Tera | Sim (template) |

**git-cliff** se destaca:
- Mais rapido (120ms)
- Mais customizavel (Tera templates)
- Suporta qualquer formato via templates
- Configuravel em `pyproject.toml` sob `[tool.git-cliff]`
- 11.5K stars, crescimento rapido
- Vencedor do segundo lugar no KaiCode Open Source Festival 2024

### 3.4 Debate: Escrever ou Gerar?

Pesquisa converge para **"gerar e curar"**: changelogs gerados sao completos mas ruidosos, escritos manualmente sao melhores para DX mas caros. Padrao emergente: LLM gera draft, humano cura.

---

## 4. Integracoes CI/CD

### 4.1 GitHub Actions

#### release-please-action
```yaml
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        id: release
        with:
          release-type: python
      - uses: actions/checkout@v4
        if: ${{ steps.release.outputs.release_created }}
      - name: Publish
        if: ${{ steps.release.outputs.release_created }}
        run: uv build && uv publish
```

**Nota**: Usar PAT em vez de `GITHUB_TOKEN` para que CI checks rodem na Release PR.

#### commitizen + git-cliff
```yaml
on:
  push:
    branches: [main]
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - run: pipx install commitizen
      - run: cz bump --yes --changelog
      - run: git push && git push --tags
```

### 4.2 GitLab CI

```yaml
release:
  stage: release
  image: python:3.12
  only: [main]
  script:
    - pip install commitizen git-cliff
    - cz bump --yes
    - git-cliff --latest > CHANGELOG.md
    - git add CHANGELOG.md && git commit --amend --no-edit
    - git push && git push --tags
```

Alternativa com semantic-release:
```yaml
release:
  stage: release
  image: node:lts
  only: [main]
  script:
    - npx semantic-release
  variables:
    GITLAB_TOKEN: $GITLAB_TOKEN
```

### 4.3 Trunk-based vs GitFlow

| Aspecto | Trunk-based | GitFlow |
|---|---|---|
| Melhor ferramenta | semantic-release, release-please | commitizen, cocogitto |
| Frequencia de release | Continua (cada merge) | Periodica (release branches) |
| CI | Pipeline unico | Pipelines por tipo de branch |

**Insight**: Trunk-based combina com automacao total (semantic-release). GitFlow combina com controle explicito (commitizen). O SDD pipeline e mais proximo de **trunk-based com gates** — implementa features, review, merge to main, release.

---

## 5. Orquestracao de Workflow

### 5.1 Three Developer Loops (Kim & Yegge, 2025)

1. **Inner Loop** (segundos-minutos): Ciclo request-output-verify com AI. Commit a cada poucos minutos (4x mais que tradicional). Specs antes de codigo.

2. **Middle Loop** (horas-dias): Continuidade entre sessoes AI. Context files (CLAUDE.md), specs estruturadas persistentes, coordenacao de multiplos agentes.

3. **Outer Loop** (semanas-meses): Orquestracao em escala. Qualidade, direcao, arquitetura.

Fonte: [IT Revolution](https://itrevolution.com/articles/the-three-developer-loops-a-new-framework-for-ai-assisted-coding/)

### 5.2 State Machines vs DAGs

State machines oferecem vantagens sobre DAGs para workflows de desenvolvimento:
- **Transicoes dinamicas**: falha em quality gate volta para implementacao (ciclos permitidos)
- **Event-driven**: transicoes por eventos (commit, PR merge, review approval)
- Ferramentas: Temporal, Restate, XState

### 5.3 Automacao de Workflow em OSS (ISR 2024)

"Workflow Automation in Open-Source Software Development" (Huang, Huang, Hong):
- Distingue **mecanizacao** (automacao de rotina) de **orquestracao** (coordenacao de tarefas criativas)
- **Orquestracao acelera resolucao de issues em 16.6%, economizando 9.1 dias por issue**

Fonte: [INFORMS](https://pubsonline.informs.org/doi/10.1287/isre.2024.1551)

### 5.4 DORA 2025

- 90% adocao de AI em desenvolvimento
- 80%+ acreditam que AI aumentou produtividade
- **AI amplifica dinamicas existentes**: times fortes melhoram, times fracos pioram
- 30% relatam pouca ou nenhuma confianca em codigo gerado por AI
- 7 capabilities amplificam impacto positivo: automated testing, version control maturity, fast feedback loops

Fonte: [DORA 2025](https://dora.dev/research/2025/dora-report/)

---

## 6. Pesquisa Academica

### 6.1 Semantic Versioning

| Paper | Venue | Finding |
|---|---|---|
| "Has My Release Disobeyed Semantic Versioning?" | ASE 2022 | Sembid: 90.26% recall, 81.29% precision para detecao de breaking semantico |
| "Breaking Bad? Semantic Versioning in Maven Central" | ESE 2022 | Maracas: analise estatica detecta violacoes semver |
| "Understanding Breaking Changes in the Wild" | ISSTA 2023 | 11.58% dos updates tem breaking changes; ~50% violam semver |

### 6.2 Commit Messages

| Paper | Venue | Finding |
|---|---|---|
| "Automated Commit Message Generation with LLMs" | IEEE TSE 2024 | ERICommiter: retrieval-augmented ICL melhora geracao |
| "Automatic Commit Message Generation: Critical Review" | IEEE TSE 2024 | Review do campo, gaps e direcoes futuras |
| "Commit Classification Using Semantic Embeddings" | PROMISE 2017 | Classificacao em adaptive/corrective/perfective |
| "Learning-based Commit Message Generation" | ASE 2024 | Abordagens learning-based para mensagens explicitas e implicitas |

### 6.3 Workflow Automation

| Paper | Venue | Finding |
|---|---|---|
| "Workflow Automation in OSS Development" | ISR 2024 | Orquestracao: +16.6% velocidade, -9.1 dias por issue |

---

## 7. Tendencias da Comunidade (2024-2026)

- **semantic-release** continua dominante (2.2M downloads/semana) mas e visto como heavyweight
- **release-please** cresce mais rapido entre alternativas (PR-based, multi-linguagem)
- **git-cliff** e a estrela em ascensao para changelogs (11.5K stars, mais customizavel)
- **Composable tools** emergem como padrao: enforcement separado de bump separado de changelog
- **LLM-assisted release**: ferramentas como Changeish usam LLMs locais para geracao de changelog
- **Hybrid repo strategy** dominante: monorepo para frontend/libs, polyrepo para microservices

---

## 8. Fontes

### Ferramentas
- [Commitizen](https://commitizen-tools.github.io/commitizen/) | [GitHub](https://github.com/commitizen-tools/commitizen)
- [Cocogitto](https://docs.cocogitto.io/) | [GitHub](https://github.com/cocogitto/cocogitto)
- [semantic-release](https://semantic-release.gitbook.io/semantic-release) | [GitHub](https://github.com/semantic-release/semantic-release)
- [release-please](https://github.com/googleapis/release-please) | [Action](https://github.com/googleapis/release-please-action)
- [git-cliff](https://git-cliff.org/) | [GitHub](https://github.com/orhun/git-cliff)
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [npm Trends](https://npmtrends.com/release-it-vs-release-please-vs-semantic-release)

### Comparacoes e Guias
- [Release-please vs semantic-release](https://www.hamzak.xyz/blog-posts/release-please-vs-semantic-release)
- [NPM Release Automation Guide](https://oleksiipopov.com/blog/npm-release-automation/)
- [Automating Python releases with commitizen](https://dteslya.engineer/blog/2023/05/18/automating-python-project-releases-with-commitizen/)
- [Trunk-based vs Git Flow](https://www.toptal.com/software/trunk-based-development-git-flow)
- [Monorepo vs Polyrepo 2025](https://dev.to/md-afsar-mahmud/monorepo-vs-polyrepo-which-one-should-you-choose-in-2025-g77)
- [GitLab CI + semantic-release](https://blogops.mixinet.net/posts/gitlab-ci/semantic-release/)

### Papers Academicos
- [Sembid (ASE 2022)](https://dl.acm.org/doi/10.1145/3551349.3556956)
- [Breaking Bad Semver (ESE 2022)](https://link.springer.com/article/10.1007/s10664-021-10052-y)
- [Breaking Changes in the Wild (ISSTA 2023)](https://dl.acm.org/doi/10.1145/3597926.3598147)
- [Commit Messages with LLMs (IEEE TSE 2024)](https://dl.acm.org/doi/10.1109/TSE.2024.3478317)
- [Commit Message Generation Review (IEEE TSE 2024)](https://dl.acm.org/doi/abs/10.1109/TSE.2024.3364675)
- [Workflow Automation in OSS (ISR 2024)](https://pubsonline.informs.org/doi/10.1287/isre.2024.1551)
- [DORA 2025](https://dora.dev/research/2025/dora-report/)
- [Three Developer Loops](https://itrevolution.com/articles/the-three-developer-loops-a-new-framework-for-ai-assisted-coding/)
