# Pesquisa: Metricas Especificas para o Pipeline SDD

Data: 2026-03-03

## Achado Central

> **"AI amplifica a qualidade do processo existente."** -- DORA 2025

Medir e melhorar a qualidade do pipeline SDD **determina diretamente** quanto valor a assistencia de AI fornece. Processos de especificacao fortes = AI acelera. Processos fracos = AI amplifica problemas.

---

## A. Metricas de Qualidade de Especificacoes

### A.1 First-Pass Review Rate (FPRR)

**Definicao**: % de specs que passam na review na primeira submissao, sem revisoes.

**Formula**: `FPRR = specs_passing_first_review / total_specs_submitted * 100%`

**Pontos de medicao** (cada review skill produz output estruturado parseavel):

| Review Skill | Criterios | First-Pass = |
|--------------|----------|--------------|
| `/discovery-review` | 6 | 6/6 PASS |
| `/prd-review` | 11 | 11/11 PASS |
| `/feature-review` | 8 | 8/8 PASS |
| `/task-review` | 8 | 8/8 PASS |

**Trending**: FPRR subindo = skill upstream melhorando ou humano fornecendo melhores inputs.

**Benchmark**: Reviews formais detectam ~60% dos defeitos. Target SDD maduro: FPRR > 80%.

### A.2 Review Findings Density (RFD)

**Definicao**: Media de achados PARTIAL ou FAIL por review, normalizado por tamanho da spec.

**Formula**: `RFD = total_findings / total_reviews` (absoluto) ou `RFD_normalized = total_findings / total_spec_lines * 1000` (por KLOL)

**Classificacao de defeitos** (IEEE requirements defect taxonomy):

| Categoria | Tipo de Review Finding | Exemplo |
|-----------|----------------------|---------|
| Missing/Incomplete | `COMPLETENESS`, `COVERAGE` | Secao faltando |
| Inconsistent | `CONSISTENCY` | Secao 4 contradiz secao 5 |
| Non-conforming | `CODEBASE`, `SIZE` | Spec diverge do codigo real |
| Ambiguous | `QUALITY` | Descricao vaga de task |
| Incorrect | `PRD-ALIGN` | Contradiz requisito do PRD |

**Trending**: U-chart (SPC). Baseline em 10-15 reviews. Tendencia descendente = melhoria.

### A.3 Spec-to-Implementation Divergence Rate (SIDR)

**Definicao**: % de requisitos DIVERGENT ou MISSING no `/impl-review`.

**Formula**: `SIDR = (DIVERGENT + MISSING) / total_requirements * 100%`

**Fonte de dados**: `/impl-review` ja produz tabela com IMPLEMENTED, PARTIAL, MISSING, DIVERGENT.

**O que SIDR revela**:
- Alto DIVERGENT: Spec correta mas implementacao desviou (problema de implementacao)
- Alto MISSING: Requisitos nunca construidos (gap em task generation/execution)
- Alto PARTIAL: Requisitos iniciados mas incompletos (problema de sizing/complexidade)

**Target**: SIDR < 10% para pipeline maduro. `/impl-review` ja define: 100% = COMPLETE, 90-99% = NEAR-COMPLETE, 70-89% = PARTIAL, < 70% = INCOMPLETE.

### A.4 Review Iteration Count (RIC)

**Definicao**: Numero de ciclos de review ate PASS.

**Interpretacao**:
- RIC = 1: First-pass success (ideal)
- RIC = 2: Uma rodada de revisoes (aceitavel)
- RIC >= 3: Problema sistemico na etapa upstream

---

## B. Metricas de Eficiencia do Pipeline

### B.1 Stage Duration

**Definicao**: Tempo de parede em cada estagio.

| Estagio | Medicao tipica |
|---------|---------------|
| `/discovery` | Tempo de entrevista + sintese AI |
| `/discovery-review` | Tempo de review AI |
| `/prd` | Ciclos Q&A + geracao AI |
| `/prd-review` | Tempo de review AI |
| `/feature-spec` | Tempo de geracao AI |
| `/feature-review` | Review AI + scan codebase |
| `/feature-to-tasks` | Tempo de geracao AI |
| `/task-review` | Tempo de review AI |
| Implementacao | Coding (humano + AI) |
| `/quality-gates` | Tempo de execucao de tools |
| `/impl-review` | Review AI + scan codebase |

**Value-Add Ratio** (Lean): `VAR = tempo_produtivo / tempo_total_pipeline * 100%`. Stages de geracao = valor. Rework loops = desperdicio.

### B.2 Rework Loops

**Definicao**: Vezes que o fluxo retorna a estagio anterior por FAIL.

**Formula**: `Rework_Rate = rework_loops / total_stage_transitions * 100%`

**Tipos de loop**:
- `/prd-review` FAIL -> revisar PRD -> `/prd-review` de novo
- `/feature-review` FAIL -> revisar spec -> `/feature-review` de novo
- `/task-review` FAIL -> revisar tasks -> `/task-review` de novo
- `/impl-review` FAIL -> corrigir implementacao -> `/impl-review` de novo

**Benchmark**: Elite teams: rework < 3%. Ambientes tipicos: 50% do tempo em rework ([KeDE Hub](https://docs.kedehub.io/kede/kede-rework-waste.html)).

### B.3 Pipeline Throughput

**Definicao**: Features completas por periodo.

**Variantes**:
- **Gross**: Todas features iniciadas
- **Net**: Features atingindo `/impl-review` PASS
- **Effective**: Features com score >= 90%

### B.4 Bottleneck Identification

**Metodo**: Theory of Constraints. Bottleneck = estagio com maior duracao media ou maior rework rate.

**Process Cycle Efficiency**: `PCE = tempo_produtivo / lead_time_total`. PCE < 25% = desperdicio significativo.

---

## C. Metricas de Fidelidade de Implementacao

### C.1 Impl-Review Score Trend

**Fonte**: `/impl-review` ja computa: `Overall = 50% * Req_Adherence + 30% * Test_Coverage + 20% * Convention_Compliance`

**Trending**: X-bar chart (SPC). Media subindo = melhoria. 7+ pontos consecutivos acima da media = shift genuino.

### C.2 Test Coverage Delta

**Formula**: `Coverage_Delta = cobertura_alcancada - cobertura_especificada`
- Delta = 0: Match exato
- Delta > 0: Over-coverage (ok)
- Delta < 0: Under-coverage (gap de qualidade)

### C.3 Convention Compliance Rate

**Categorias** (do `/impl-review`):
1. Type hints
2. Docstrings
3. Exception chaining
4. Structured logging
5. Config models
6. Async patterns
7. Import ordering
8. Test naming

### C.4 Defect Escape Rate

**Formula**: `DER = defeitos_pos_review / (defeitos_na_review + defeitos_pos_review) * 100%`

Equivale ao Defect Detection Percentage (DDP). DDP > 90% = review pipeline captura 90%+ dos defeitos.

**Fonte de dados**: Commits `fix()` apos `/impl-review` PASS = defeitos escapados.

---

## D. Metricas Especificas de AI

### D.1 Token Cost per Feature

**Formula**: `Token_Cost = sum(input_tokens + output_tokens)` em todas invocacoes por feature.

**Otimizacoes**:
- Caching de prompts reutilizaveis (system prompts, skill definitions)
- Model routing (modelos mais baratos para etapas simples)
- Context window optimization (enviar so codigo relevante)

### D.2 Context Window Utilization

**Formula**: `CWU = tokens_usados / max_context_window * 100%`

| CWU | Status |
|-----|--------|
| < 50% | Headroom confortavel |
| 50-75% | Monitorar |
| 75-90% | Risco de degradacao |
| > 90% | Truncation/quality loss provavel |

Skills mais em risco: `/feature-review` e `/impl-review` (spec + PRD + CLAUDE.md + CONVENTIONS.md + codebase scan).

### D.3 First-Attempt Success Rate (FASR)

**Definicao**: % de artefatos AI que passam review **sem edição humana**.

Difere de FPRR: se humano edita spec antes de submeter a review e passa, FPRR = 100% mas FASR < 100%.

### D.4 Human Intervention Frequency

| Tipo | Descricao | Medicao |
|------|----------|---------|
| **Corrective** | Humano corrige output AI antes da review | Count + tempo |
| **Directive** | Humano fornece guidance adicional | Count + tokens |
| **Override** | Humano sobrescreve decisao AI | Count + justificativa |
| **Approval** | Humano aprova sem mudanca | Count (custo minimo) |

**Trending**: Com maturidade, corrective diminui e approval aumenta.

---

## E. Rastreabilidade via Git

### E.1 Feature-to-Commit Traceability

**Formula**: `Traceability = commits_com_feature_scope / total_commits * 100%`

**Implementacao**: Scope do conventional commit = feature ID (`feat(F6): ...`). Parse `git log`.

### E.2 Commit Granularity Score

| Sub-metrica | Formula | Target |
|-------------|---------|--------|
| Files per commit | `avg(files_per_commit)` | 1-5 |
| Lines per commit | `avg(lines_per_commit)` | 10-100 |
| Single-concern | `commits_um_modulo / total` | > 80% |
| Message quality | `commits_com_type_e_scope / total` | 100% |

### E.3 Fix-After-Implement Ratio (FAIR)

**Formula**: `FAIR = fix_commits_feature / feat_commits_feature` (janela 2 semanas pos-completion)

**Interpretacao**:
- FAIR = 0.0: Nenhum fix (ideal)
- FAIR = 0.0-0.1: Correcoes menores (aceitavel)
- FAIR > 0.2: Defeitos significativos (gap em spec ou review)

### E.4 Changelog Completeness

**Formula**: `Completeness = features_no_changelog / features_completas * 100%`

Auto-gerado de conventional commits = ~100%.

### E.5 Code Churn Rate (pos-implementacao)

**Formula**: `Churn = linhas_modificadas_na_janela / total_linhas_adicionadas * 100%`

GitClear define churned code = codigo escrito e revertido/alterado em 2 semanas. Elite teams: churn < 5%.

---

## F. Metricas de Evolucao do Processo

### F.1 Impacto de Mudanca em Skill

**Metodo: Interrupted Time Series Analysis**

1. Baseline: 15-20 data points antes da mudanca
2. Introduzir mudanca na skill
3. Coletar 15-20 data points pos-mudanca
4. Analisar: two-sample t-test ou Mann-Whitney U para shift significativo

**SPC**: Pontos fora UCL/LCL ou padrao (7+ consecutivos acima/abaixo da media) = efeito estatisticamente significativo.

### F.2 A/B Testing para Mudancas de Processo

| Metodo | Quando usar | Sample size |
|--------|------------|-------------|
| Alternacao intra-projeto | Skill antiga/nova em features alternadas | 10+ por variante |
| Comparacao cross-project | Skill nova em projeto novo vs anterior | 2+ projetos |
| Before/after com wash-out | Baseline, mudar, medir apos estabilizacao | 15+ cada |
| Paired comparison | Gerar spec com ambas skills para mesma feature | 5+ pares |

**Significancia**: p < 0.05. Para amostras pequenas: Mann-Whitney U, Wilcoxon signed-rank. Para proporcoes (FPRR): Fisher's exact test.

### F.3 Process Maturity Score

| Level | Nome | Criterio |
|-------|------|---------|
| 1 | **Initial** | Pipeline existe mas sem metricas |
| 2 | **Measured** | Metricas A-E sendo coletadas |
| 3 | **Controlled** | Control charts ativos, baseline estabelecido |
| 4 | **Optimizing** | Mudancas validadas com analise estatistica |
| 5 | **Predictive** | Dados historicos predizem duracao e qualidade |

---

## G. Ferramentas e Dashboards

### Git Analytics

| Ferramenta | Forca | Relevancia SDD |
|------------|-------|---------------|
| [GitClear](https://www.gitclear.com/) | Line Impact, code churn, AI detection | Churn rate, FAIR, granularity |
| [Githru](https://github.com/githru/githru) | Visual analytics git | Visualizacao pipeline |
| [LinearB](https://linearb.io/) | Cycle time, rework, DORA | Pipeline efficiency |
| [Jellyfish](https://jellyfish.co/) | AI impact, engineering ROI | Metricas AI |
| [CodeScene](https://codescene.com/) | Hotspots, coupling, complexity | Tornhill's approach |

### Changelog e Traceability

| Ferramenta | Proposito |
|------------|----------|
| [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog) | Changelog auto de commits |
| [git-cliff](https://git-cliff.org/) | Changelog customizavel |
| [semantic-release](https://github.com/semantic-release/commit-analyzer) | Bump + changelog auto |
| [commitlint](https://commitlint.js.org/) | Enforcar conventional commits |

### Custom Dashboard para SDD

Review skills ja produzem output estruturado — basta:
1. Parsear review outputs (PASS/PARTIAL/FAIL/MISSING)
2. Parsear impl-review scores (%)
3. Parsear quality-gate outputs
4. Correlacionar com git (feature ID -> commit scopes)
5. Armazenar como time series (JSON ou SQLite)
6. Visualizar com control charts (SPC)

---

## H. Prioridade de Implementacao

### Fase 1: Imediato (dados ja disponiveis nos outputs de review)

| Metrica | Fonte | Esforco |
|---------|-------|---------|
| First-Pass Review Rate (A.1) | Contar review runs | Baixo |
| Review Findings Density (A.2) | Parsear review tables | Baixo |
| Impl-Review Score Trend (C.1) | Parsear score section | Baixo |
| Rework Loops (B.2) | Contar re-runs | Baixo |

### Fase 2: Integracao Git (requer git log parsing)

| Metrica | Fonte | Esforco |
|---------|-------|---------|
| Feature-to-Commit Traceability (E.1) | `git log` scope parsing | Medio |
| Commit Granularity (E.2) | `git log --stat` | Medio |
| Fix-After-Implement Ratio (E.3) | `git log --grep` + date filter | Medio |
| Changelog Completeness (E.4) | Comparar features vs changelog | Medio |

### Fase 3: Instrumentacao (requer tooling no pipeline)

| Metrica | Fonte | Esforco |
|---------|-------|---------|
| Stage Duration (B.1) | Timestamp cada skill | Medio-Alto |
| Token Cost per Feature (D.1) | API usage tracking | Medio-Alto |
| Context Window Utilization (D.2) | Token count por invocacao | Medio-Alto |
| Human Intervention Tracking (D.4) | Anotacao de edits humanos | Alto |

### Fase 4: Analise Estatistica (requer baseline)

| Metrica | Fonte | Esforco |
|---------|-------|---------|
| Control Charts (F.1) | 15+ data points | Requer Fase 1-3 |
| Skill Change Impact (F.1) | Before/after comparison | Requer baseline |
| Process Maturity Score (F.3) | Composito de todas metricas | Requer todas fases |

---

## Metricas Mapeadas por Estagio do Pipeline

| Estagio | Metricas Chave | Fontes |
|---------|---------------|--------|
| `/discovery` | Requirement completeness, stakeholder coverage | GQM |
| `/discovery-review` | Review pass rate, volatility prediction | IEEE |
| `/prd` | Requirement count, NFR coverage (ISO 25010) | ISO/IEC 25010 |
| `/prd-review` | Spec volatility index | IEEE RVI |
| `/feature-spec` | Spec coverage ratio, testable requirement count | RTM, SDD arXiv |
| `/feature-review` | Review iteration count, defects at spec level | DRE (Capers Jones) |
| `/feature-to-tasks` | Task atomicity (commits/task), task-to-spec traceability | MSR |
| Implementacao (TDD) | CC, CK, Halstead, test coverage | McCabe, CK, Halstead |
| `/quality-gates` | DRE at gate, security vuln rate, duplication | Capers Jones, GitClear |
| `/impl-review` | Spec adherence, rework ratio, code churn | Nagappan, Tornhill, SDD |
| Pipeline geral | DORA, SPACE, first-pass rate, hotspot trend | DORA, SPACE, Tornhill |
