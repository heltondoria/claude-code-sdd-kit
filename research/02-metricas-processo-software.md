# Pesquisa: Metricas de Processo de Software

Data: 2026-03-03

## 1. Metricas Tradicionais

### 1.1 DORA Metrics

**Fonte**: Google DORA program (Forsgren, Humble, Kim). [DORA Metrics Guide](https://dora.dev/guides/dora-metrics/) | [DORA 2025 Report](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)

**Cinco metricas** (expandido de 4 em 2024):

| Metrica | Definicao | Categoria |
|---------|----------|-----------|
| **Deployment Frequency** | Frequencia de deploy em producao | Throughput |
| **Lead Time for Changes** | Tempo do commit ate producao | Throughput |
| **Change Failure Rate** | % de deploys que causam falha | Stability |
| **Failed Deployment Recovery Time** (ex-MTTR) | Tempo para recuperar de deploy falho | Throughput (reclassificado 2024) |
| **Rework Rate** (novo 2024) | Proporcao de deploys nao-planejados para corrigir issues | Stability |

**Evolucao 2025**: Substituiu classificacao elite/high/medium/low por **7 arquetipos de time**: "Harmonious High-Achievers" (20%), "Stable and Methodical", "High Impact Low Cadence", "Legacy Bottleneck", "Constrained by Process", e "Foundational Challenges" (10%).

**Achado sobre AI** ([Faros AI](https://www.faros.ai/blog/key-takeaways-from-the-dora-report-2025)): AI coding assistants aumentam output individual (21% mais tasks, 98% mais PRs merged) mas metricas DORA organizacionais **ficam flat** -- ganhos individuais nao se traduzem em melhoria organizacional.

**Adaptacao para SDD**:

| DORA | Adaptacao SDD | Medicao |
|------|--------------|---------|
| Deployment Frequency | Feature Completion Frequency | Features passando impl-review por periodo |
| Lead Time | Pipeline Lead Time | Tempo de /discovery ate /impl-review PASS |
| Change Failure Rate | Post-Review Defect Rate | Defeitos apos /impl-review PASS |
| MTTR | Rework Recovery Time | Tempo de FAIL ate proximo PASS em qualquer review |
| Rework Rate | Fix-After-Implement Ratio | Commits fix apos feature completa |

---

### 1.2 GQM (Goal-Question-Metric)

**Fonte**: Victor R. Basili, University of Maryland / NASA SEL. [Paper original](https://www.cs.umd.edu/users/mvz/handouts/gqm.pdf)

**Framework de 3 niveis**:
1. **Goal**: Definir objetivo de medicao (objeto, proposito, foco de qualidade, viewpoint, contexto)
2. **Question**: Perguntas que operacionalizam o goal
3. **Metric**: Metricas quantitativas/qualitativas que respondem cada pergunta

**Exemplo SDD**:

| Goal | Question | Metrics |
|------|----------|---------|
| Melhorar qualidade de specs | Specs estao passando na review na primeira tentativa? | First-pass review rate, findings por spec |
| Reduzir esforco desperdicado | Onde retrabalho se concentra? | Rework loops por etapa, fix-after-implement ratio |
| Maximizar eficiencia da AI | AI esta gerando artefatos mais corretos? | Token cost por feature, first-attempt success rate |
| Garantir rastreabilidade | Cada linha de codigo rastreia a um requisito? | Traceability coverage %, orphan code ratio |

**Por que importa**: GQM e a **metodologia para selecionar metricas**, nao as metricas em si. Previne o anti-padrao "medir por medir". Toda metrica deve rastrear a um Goal.

---

### 1.3 CK Metrics (Chidamber-Kemerer)

**Fonte**: Chidamber & Kemerer, [IEEE TSE 1994](https://sites.pitt.edu/~ckemerer/CK%20research%20papers/MetricForOOD_ChidamberKemerer94.pdf). Validado por [Basili, Briand, Melo (IEEE TSE 2003)](https://ieeexplore.ieee.org/document/1191795/).

| Metrica | O que mede |
|---------|-----------|
| **WMC** | Soma das complexidades de metodos por classe. Alto = mais defeitos |
| **DIT** | Profundidade na arvore de heranca. Profundo = mais complexidade herdada |
| **NOC** | Numero de subclasses imediatas. Alto = alto reuso mas alta responsabilidade |
| **CBO** | Acoplamento entre classes. Alto = dificil testar e reusar |
| **RFC** | Metodos potencialmente executados em resposta a mensagem |
| **LCOM** | Falta de coesao em metodos. Alto = classe deve ser dividida |

**Validacao**: "Significativamente associado com determinacao de defeitos, mesmo controlando tamanho do software" (Basili et al.).

**Uso no SDD**: Quality gates automatizados com thresholds (CBO <= 10, LCOM1 ~ 0, WMC <= 20). Rastrear tendencias de CK em codigo AI para detectar design acoplado.

---

### 1.4 Halstead Complexity

**Fonte**: Maurice Halstead, *Elements of Software Science*, 1977. Purdue University.

| Metrica | Formula | Interpretacao |
|---------|---------|--------------|
| **Vocabulary** (n) | n1 + n2 | Tokens unicos |
| **Length** (N) | N1 + N2 | Total de tokens |
| **Volume** (V) | N * log2(n) | Conteudo informacional |
| **Difficulty** (D) | (n1/2) * (N2/n2) | Dificuldade de compreensao |
| **Effort** (E) | V * D | Esforco cognitivo estimado |
| **Estimated Bugs** (B) | V / 3000 | Predicao de defeitos |

**Uso no SDD**: Effort (E) rastreado por feature para ver se implementacoes AI ficam mais faceis de revisar. Estimated Bugs (B) comparado com defeitos reais encontrados no /impl-review.

---

### 1.5 McCabe Cyclomatic Complexity

**Fonte**: Thomas McCabe, [IEEE TSE 1976](https://en.wikipedia.org/wiki/Cyclomatic_complexity). Validado por [NIST](https://www.mccabe.com/pdf/mccabe-nist235r.pdf).

**Definicao**: Numero de caminhos linearmente independentes pelo codigo. `M = E - N + 2P`

| CC | Risco | Recomendacao |
|----|-------|-------------|
| 1-10 | Baixo | Bem estruturado, facil testar |
| 11-20 | Moderado | Precisa atencao |
| 21-50 | Alto | Refatorar |
| 50+ | Muito alto | Intestavel, dividir |

**Achado**: "Funcoes com maior complexidade contem mais defeitos" -- correlacao positiva forte confirmada em multiplos estudos.

**Uso no SDD**: Gate hard em /quality-gates (CC <= 10). CC determina numero minimo de test cases para cobertura de caminhos (liga diretamente com TDD). CC crescente = specs sub-especificando complexidade comportamental.

---

### 1.6 ISO/IEC 25010 (Software Quality Model)

**Fonte**: [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html)

**8 caracteristicas de qualidade de produto**:

1. **Functional Suitability**: Completeness, Correctness, Appropriateness
2. **Performance Efficiency**: Time behavior, Resource utilization, Capacity
3. **Compatibility**: Co-existence, Interoperability
4. **Usability**: Learnability, Operability, User error protection, Accessibility
5. **Reliability**: Maturity, Availability, Fault tolerance, Recoverability
6. **Security**: Confidentiality, Integrity, Non-repudiation, Accountability, Authenticity
7. **Maintainability**: Modularity, Reusability, Analyzability, Modifiability, Testability
8. **Portability**: Adaptability, Installability, Replaceability

**Uso no SDD**: Taxonomia de qualidade para specs referenciarem. Feature specs devem mapear NFRs para caracteristicas ISO 25010. Maintainability mapeia diretamente para metricas CK e CC.

---

### 1.7 Defect Density e Defect Removal Efficiency (DRE)

**Fonte**: Capers Jones. [DRE Paper](https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Defect-Removal-Efficiency.pdf) | [Quality Metrics Paper](https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Quality-Metrics-Capers-Jones-120607.pdf)

**Defect Density**: `DD = Total Defects / Size (KLOC ou Function Points)`
- Media EUA: ~0.75 defeitos por function point
- Bom: 600-1000 defeitos por MLOC
- Excepcional: < 600 defeitos por MLOC

**DRE**: `DRE = Defeitos encontrados antes do release / Total defeitos * 100`
- Media EUA: ~92.5%
- **DRE < 85%**: "Sempre atrasa, sempre estoura orcamento, clientes insatisfeitos"
- **DRE > 95%**: "Geralmente no prazo, geralmente abaixo do orcamento"
- Capers Jones chama DRE de "a metrica de qualidade mais poderosa e util ja desenvolvida"

**Uso no SDD**: DRE por estagio do pipeline — % de defeitos que cada review catch antes de producao. DRE alto nos estagios de spec = pipeline funcionando (shift left).

---

### 1.8 Code Churn como Preditor de Qualidade

**Fonte**: Nagappan & Ball, Microsoft Research, [ICSE 2005](https://www.microsoft.com/en-us/research/publication/use-of-relative-code-churn-measures-to-predict-system-defect-density/). [GitClear 2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research).

**Achado**: Churn absoluto e preditor **fraco**. Churn **relativo** e altamente preditivo:
- Churned LOC / Total LOC
- Deleted LOC / Total LOC
- Files churned / Total files

**Dados sobre AI** (GitClear, 211M linhas):
- Short-term churn subiu de 5.5% (2020) para 7.9% (2024)
- Code duplication subiu de 8.3% para 12.3%
- Refactoring caiu de 25% para < 10%

**Uso no SDD**: Churn de curto prazo = spec unclear ou AI implementation errada. Rastrear como "spec clarity index" (inverso do churn). Elite teams mantem churn < 5%.

---

## 2. Frameworks de Produtividade

### 2.1 SPACE Framework

**Fonte**: Forsgren, Storey, Maddila et al. [ACM Queue 2021](https://queue.acm.org/detail.cfm?id=3454124)

| Dimensao | O que mede | Exemplos |
|----------|-----------|----------|
| **Satisfaction** | Como devs se sentem sobre trabalho/ferramentas | Surveys, burnout rate |
| **Performance** | Resultado do sistema/processo | Code quality, bug rates, cycle times |
| **Activity** | Trabalho realizado | Commit frequency, PR volume |
| **Communication** | Qualidade de colaboracao | Review quality, onboarding time |
| **Efficiency** | Progresso suave com minimas interrupcoes | Cycle time, deployment frequency |

**Principio chave**: "Produtividade nao pode ser capturada por nenhuma metrica unica."

### 2.2 DX Core 4

**Fonte**: Forsgren et al. [DX Research](https://getdx.com/research/measuring-developer-productivity-with-the-dx-core-4/)

| Dimensao | O que mede |
|----------|-----------|
| **Speed** | Quao rapido devs entregam codigo funcional |
| **Effectiveness** | Quao bem processos suportam engenheiros (DXI - 14 fatores) |
| **Quality** | Software estavel e confiavel em producao |
| **Impact** | Quanto valor devs criam alem de escrever codigo |

**"Metricas oposicionais"**: Speed sem effectiveness = ruim. Impact sem quality = ruim.

**Dado**: Melhorar DXI em 1 ponto = 13 minutos salvos/semana/dev = 10h/ano.

---

## 3. Commit-Based Metrics e MSR

### 3.1 Mining Software Repositories

**Fonte**: Comunidade MSR (ACM/IEEE, desde 2004). [Teaching MSR (arXiv 2025)](https://arxiv.org/html/2501.01903v1). Tools: [PyDriller](https://github.com/ishepard/pydriller).

Commit history revela:
- **Frequencia**: Consistente = planejamento saudavel. Bursts = problemas.
- **Tamanho**: Muito grandes = decomposicao ruim. Muito pequenos = cerimonia excessiva.
- **Fix/feature ratio**: Alto ratio fix/feat = problemas de qualidade.

### 3.2 Bus Factor

**Fonte**: Avelino et al. (2016). [Soto-Valero (2023)](https://www.cesarsotovalero.net/blog/bus-factor-a-human-centered-risk-metric-in-the-software-supply-chain.html).

- 65% dos projetos GitHub tem bus factor <= 2
- < 10% tem bus factor > 10
- Com AI, "code comprehension factor" importa mais que autoria

### 3.3 Hotspot Analysis

**Fonte**: Adam Tornhill, [*Your Code as a Crime Scene*](https://pragprog.com/titles/atcrime2/your-code-as-a-crime-scene-second-edition/) (2015, 2nd ed. 2024).

Hotspot = arquivo **complexo** + **frequentemente alterado**.

**Achado**: Em case study (400 KLOC, 89 devs, 18K+ commits), hotspots apontaram 7 de 8 partes mais defeituosas. **4% do codigo responsavel por 72% dos defeitos.**

### 3.4 Commit Coupling (Temporal/Logical)

**Fonte**: Tornhill; Gall, Hajek, Jazayeri (1998).

Arquivos que mudam juntos frequentemente = acoplamento logico. Pode existir sem dependencia estatica. Revela issues de arquitetura ocultos.

### 3.5 Rework Ratio

**Fonte**: [Herbold et al. (Empirical SE, 2021)](https://link.springer.com/article/10.1007/s10664-021-10051-z).

- 1-5% dos commits sao revertidos
- 17-32% das mudancas em bug-fixing commits realmente corrigem o problema (resto = tangled)

---

## 4. AI-Assisted Development Metrics

### 4.1 Eficacia de AI

**Fontes**: [DORA 2025](https://dora.dev/research/2025/dora-report/), [GitClear 2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research), [CodeRabbit Report](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report), [METR Study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/).

| Metrica | Valor | Fonte |
|---------|-------|-------|
| Acceptance rate (Copilot) | ~30% | Industry reports |
| Experienced dev acceptance | 45-54% | Enterprise studies |
| Self-reported productivity | 12-15% mais codigo | Industry stats |
| DORA organizacional | **Flat** (sem melhoria) | Faros AI / DORA 2025 |
| Senior dev com AI | **19% mais lento** | METR RCT |
| Issues por PR (AI) | **1.7x mais** que humano | CodeRabbit |
| Security vulnerabilities (AI Python) | **29.5%** dos snippets | Georgetown CSET |

### 4.2 Qualidade AI vs Humano

**Fonte**: [CodeRabbit Dec 2025](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report). [arXiv:2508.21634](https://arxiv.org/abs/2508.21634) (500K+ samples). [Georgetown CSET](https://cset.georgetown.edu/wp-content/uploads/CSET-Cybersecurity-Risks-of-AI-Generated-Code.pdf).

| Metrica | AI | Humano |
|---------|-----|--------|
| Issues/PR | 10.83 | 6.45 |
| Critical issues | 1.4x mais | Baseline |
| Logic/correctness | +75% | Baseline |
| Code duplication | 12.3% | 8.3% |
| Short-term churn | 7.9% | 5.5% |
| Refactoring | < 10% | 25% |

**Insight critico**: "AI gera mais codigo mas nao forca boas praticas como reuso, modularidade e testes completos" (GitClear).

---

## 5. Metricas para Medir Melhoria de Processo

### 5.1 Martin Fowler

**Fontes**: [Cannot Measure Productivity](https://martinfowler.com/bliki/CannotMeasureProductivity.html), [Developer Effectiveness](https://martinfowler.com/articles/developer-effectiveness.html), [Quality with AI Agents](https://martinfowler.com/articles/exploring-gen-ai/ccmenu-quality.html).

- "Nao podemos medir produtividade porque nao podemos medir output" -- LOC penaliza codigo bem fatorado.
- Unica medida real = **valor de negocio entregue**.
- **Goodhart's Law**: "Quando uma medida se torna um alvo, deixa de ser uma boa medida."
- Foco em **outcomes over output**.
- Metricas qualitativas podem ser mais significativas que quantitativas.

### 5.2 Statistical Process Control (SPC)

**Fonte**: [IEEE 2013](https://ieeexplore.ieee.org/document/6681375/). CMMI-DEV 1.3 Level 4.

- **Control Charts**: Metrica plotada ao longo do tempo com UCL/LCL (+/- 3 desvios padrao).
- **Common Cause Variation**: Variacao normal, inerente ao processo.
- **Special Cause Variation**: Algo mudou (ferramenta nova, processo modificado).
- 7+ pontos consecutivos acima/abaixo da media = shift significativo.

**Limitacao**: "Complexidade, conformidade, mutabilidade e invisibilidade do software resulta em variacao inerente que nao pode ser removida, implicando que SPC e menos efetivo em software do que em manufatura."

---

## 6. SDD na Literatura Academica

### 6.1 Constitutional SDD

**Fonte**: [arXiv:2602.02584](https://arxiv.org/abs/2602.02584)

Embeda principios de seguranca nao-negociaveis na camada de especificacao. Compliance traceability matrix gerada sistematicamente. **Reduziu defeitos de seguranca em 73%** comparado com geracao AI sem restricoes.

### 6.2 SDD: From Code to Contract

**Fonte**: [arXiv:2602.00180](https://arxiv.org/abs/2602.00180)

3 niveis de rigor:
- **Spec-first**: Spec escrita antes do codigo, codigo verificado contra spec.
- **Spec-anchored**: Spec evolui com codigo mas permanece autoritativa.
- **Spec-as-source**: Spec E o codigo (metodos formais, specs executaveis).

### 6.3 CURRANTE

**Fonte**: [arXiv:2601.03878](https://arxiv.org/abs/2601.03878)

Plugin VS Code que implementa workflow TDD com LLMs gerando codigo baseado em specs formalmente definidas via test cases.

### 6.4 LLMs para Documentation-to-Code Traceability

**Fonte**: [arXiv:2506.16440](https://arxiv.org/html/2506.16440v1)

Rastreabilidade = estabelecer relacoes entre artefatos (requirements, design, source code, test cases, docs). Habilita impact analysis, change management, compliance verification.

---

## Referencias Completas

### Academicas
- [Basili - GQM Approach](https://www.cs.umd.edu/users/mvz/handouts/gqm.pdf)
- [Chidamber & Kemerer - CK Metrics (IEEE TSE 1994)](https://sites.pitt.edu/~ckemerer/CK%20research%20papers/MetricForOOD_ChidamberKemerer94.pdf)
- [Basili, Briand, Melo - CK Validation (IEEE TSE 2003)](https://ieeexplore.ieee.org/document/1191795/)
- [Nagappan & Ball - Code Churn (ICSE 2005)](https://www.microsoft.com/en-us/research/publication/use-of-relative-code-churn-measures-to-predict-system-defect-density/)
- [Forsgren et al. - SPACE Framework (ACM Queue 2021)](https://queue.acm.org/detail.cfm?id=3454124)
- [SPC Applied to Software (IEEE 2013)](https://ieeexplore.ieee.org/document/6681375/)
- [Requirements Volatility (IEEE)](https://ieeexplore.ieee.org/document/1290455/)
- [Herbold et al. - Rework (Empirical SE 2021)](https://link.springer.com/article/10.1007/s10664-021-10051-z)
- [Human vs AI Code (arXiv:2508.21634)](https://arxiv.org/abs/2508.21634)
- [SDD: Code to Contract (arXiv:2602.00180)](https://arxiv.org/abs/2602.00180)
- [Constitutional SDD (arXiv:2602.02584)](https://arxiv.org/abs/2602.02584)
- [Schneidewind - Metrics Validation (IEEE TSE)](https://dl.acm.org/doi/10.1109/32.135774)
- [IEEE 1061 - Quality Metrics Methodology](https://standards.ieee.org/ieee/1061/1549/)

### Industria
- [DORA Metrics Guide](https://dora.dev/guides/dora-metrics/)
- [DORA 2025 Report](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)
- [Faros AI - DORA 2025](https://www.faros.ai/blog/key-takeaways-from-the-dora-report-2025)
- [GitClear AI Code Quality 2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research)
- [CodeRabbit AI vs Human Report](https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report)
- [Capers Jones - DRE](https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Defect-Removal-Efficiency.pdf)
- [Capers Jones - Quality Metrics](https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Quality-Metrics-Capers-Jones-120607.pdf)
- [Fowler - Cannot Measure Productivity](https://martinfowler.com/bliki/CannotMeasureProductivity.html)
- [Fowler - Developer Effectiveness](https://martinfowler.com/articles/developer-effectiveness.html)
- [Tornhill - Your Code as a Crime Scene](https://pragprog.com/titles/atcrime2/your-code-as-a-crime-scene-second-edition/)
- [DX Core 4](https://getdx.com/research/measuring-developer-productivity-with-the-dx-core-4/)
- [Jellyfish AI Impact 2025](https://jellyfish.co/blog/2025-ai-metrics-in-review/)
- [METR AI Impact Study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
- [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html)
- [Georgetown CSET AI Security](https://cset.georgetown.edu/wp-content/uploads/CSET-Cybersecurity-Risks-of-AI-Generated-Code.pdf)
