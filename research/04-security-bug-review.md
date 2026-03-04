# Pesquisa: Revisao de Seguranca e Deteccao de Bugs com IA

Data: 2026-03-03

## 1. Skill vs Agent no Claude Code — Diferenca Pratica

| Aspecto | Skill | Agent (Subagent) |
|---------|-------|------------------|
| **Invocacao** | `/skill-name` ou automatica (Claude detecta relevancia) | Delegacao explicita ou automatica |
| **Contexto** | Roda inline na conversa principal | Contexto isolado (fresh) |
| **System prompt** | Instrucoes mescladas ao prompt existente | System prompt customizado |
| **Ferramentas** | Herda do pai, pode restringir com `allowed-tools` | Herda do pai, pode restringir via `tools` |
| **Resultado** | Fica na thread da conversa | Resumido e retornado |
| **Modelo** | Herda da sessao (pode sobrescrever) | Pode usar modelo diferente |

### Quando usar cada um

**Skill**: workflows reutilizaveis que rodam no contexto principal, tarefas autocontidas, quando o contexto precisa ser preservado.

**Agent**: tarefas que precisam de isolamento completo, output verboso que nao deve poluir o contexto principal, quando se quer restringir ferramentas (ex: read-only).

### Recomendacao para Security/Bug Review

**Agent e a melhor escolha** porque:
- Output de review e verboso — isolamento preserva o contexto principal
- Pode restringir a ferramentas read-only (`Read, Grep, Glob, Bash`)
- Foco total na tarefa sem drift
- System prompt customizado para padroes de seguranca

**Alternativa hibrida**: usar um hook `Stop` que sugere rodar o agent apos mudancas de codigo.

---

## 2. Padroes de Vulnerabilidades/Bugs Detectaveis por LLMs

### 2.1 Alta Confiabilidade (LLMs detectam bem)

| Padrao | CWE | Descricao |
|--------|-----|-----------|
| SQL Injection | CWE-89 | Queries com input nao sanitizado |
| Command Injection | CWE-78 | Execucao de comandos com input do usuario |
| Path Traversal | CWE-22 | Input nao sanitizado em caminhos de arquivo |
| XXE | CWE-611 | Parsing XML com entidades externas |
| Null Pointer Deref | CWE-476 | Acesso sem checagem de null |
| Buffer Overflow | CWE-120/119 | Copia sem verificacao de limites |
| Hardcoded Secrets | CWE-798 | API keys, senhas, tokens no codigo |
| Use-After-Free | CWE-416 | Acesso a memoria apos liberacao |
| Resource Leaks | CWE-404/772 | Handles nao fechados (files, connections) |
| Crypto Fraca | CWE-327/330 | Algoritmos fracos, PRNG inseguro |

### 2.2 Confiabilidade Moderada

| Padrao | CWE | Nota |
|--------|-----|------|
| TOCTOU Race Condition | CWE-367 | Entende o conceito mas perde instancias sutis |
| Integer Overflow | CWE-190 | Casos obvios sim, pipelines aritmeticos complexos nao |
| Off-by-One | CWE-193 | Loops simples sim, iteracao complexa nao |

### 2.3 Baixa Confiabilidade (precisa abordagem hibrida)

- Falhas de logica de autorizacao complexa (CWE-285/862)
- Vulnerabilidades de fluxo de dados cross-function profundo
- Bugs de concorrencia alem de TOCTOU basico

---

## 3. Estudos e Resultados Relevantes

### 3.1 BugStone — "One Bug, Hundreds Behind" (arxiv 2510.14036)

**Conceito-chave**: Recurring Pattern Bugs (RPBs) — bugs que compartilham uma causa raiz e aparecem em multiplos locais.

- Analisou 148K+ trechos de codigo
- **92.2% de precisao** e 79.1% de acuracia pareada
- Dataset de 850 patches em 80 padroes recorrentes
- Insight: a partir de UM exemplo de bug, LLMs encontram instancias similares sistematicamente

### 3.2 IRIS — LLM-Assisted Static Analysis (arxiv 2405.17238)

- IRIS com GPT-4 detectou **55 vulnerabilidades vs 27 do CodeQL** (103.7% mais)
- Reduziu falsos positivos em 5 pontos percentuais
- Identificou **4 vulnerabilidades previamente desconhecidas**
- Modelos menores (DeepSeekCoder 7B) tambem detectaram 52 vulnerabilidades

### 3.3 ZeroFalse — Specialized Prompting (arxiv 2510.02534)

- **Prompts especializados por CWE superam prompts genericos significativamente**
- F1 = 0.912 (OWASP), F1 = 0.955 (OpenVuln)
- Chave: adaptar o prompt ao tipo especifico de vulnerabilidade

### 3.4 Semgrep + LLM (simple_semgrepAI)

- Pipeline de 2 estagios: Semgrep SAST -> LLM validacao
- **Precisao saltou de 35.7% (Semgrep puro) para 89.5%** com LLM
- Falsos positivos reduzidos para ~1/11

### 3.5 "Can LLMs Find Bugs in Code?" (arxiv 2508.16419)

- Todos os modelos se destacam em issues sintaticos/semanticos em codigo bem escopo
- Performance diminui para vulnerabilidades complexas e codigo grande
- ChatGPT-4 e Claude 3 deram analises mais nuancadas que LLaMA 4

---

## 4. O Que o Ecosistema Claude Code Ja Oferece

### 4.1 `/security-review` (built-in)

Claude Code ja vem com um comando `/security-review` que checa:
- Injection attacks (SQL, command, LDAP, XPath, NoSQL, XXE)
- Auth & authorization (broken auth, privilege escalation, IDOR, session flaws)
- Data exposure (hardcoded secrets, sensitive data logging, PII)
- Cryptographic issues (weak algorithms, key management, PRNG)

### 4.2 GitHub Action `anthropics/claude-code-security-review`

- Analisa apenas arquivos alterados em PRs (diff-aware)
- Posta findings como comentarios no PR
- Language-agnostic
- Inclui filtragem de falsos positivos

### 4.3 Semgrep MCP Server (`semgrep/mcp`)

- Integra Semgrep diretamente no Claude Code via MCP
- 5000+ regras built-in
- Scan de codigo, supply chain e secrets

---

## 5. Abordagem Hibrida Recomendada (Shift-Left)

A pesquisa converge para um modelo de camadas. **As camadas 1-3 sao 100% locais**
— funcionam sem CI, sem plataforma especifica, sem cloud. A Camada 4 e opcional
e funciona em qualquer CI (GitLab CI, GitHub Actions, Jenkins, etc.).

### Camada 1: Write-time (hooks Claude Code) — local
- Ruff S rules no edit/write (ja temos)
- detect-secrets para credenciais

### Camada 2: Quality gates (CLI local, sob demanda) — local
- Semgrep local scan (`semgrep --config auto . --error`)
- detect-secrets com baseline
- Roda via `/quality-gates` ou manualmente

### Camada 3: Review (nosso foco) — local
- **Agent de seguranca/bugs com prompts CWE-especializados**
- Analise contextual que vai alem do pattern matching
- Filtragem de falsos positivos de ferramentas SAST
- Roda no Claude Code sem dependencia de plataforma

### Camada 4: CI (opcional, qualquer plataforma)
- Semgrep full scan (GitLab CI, GitHub Actions, Jenkins, etc.)
- Dependency scanning
- Secret detection (repo inteiro)
- **Nao e pre-requisito** — as camadas 1-3 ja cobrem o essencial

---

## 6. Conclusoes para o SDD Kit

### 6.1 Formato: Agent (nao skill)

- Output verboso de review precisa de isolamento
- Pode restringir a read-only tools
- System prompt customizado com padroes especificos
- Pode usar modelo diferente (sonnet para custo/velocidade)

### 6.2 Abordagem: CWE-Specialized Prompting

- **NAO** usar prompt generico "encontre vulnerabilidades"
- Dividir em categorias de padroes com instrucoes especificas por tipo
- Baseado no estudo ZeroFalse: F1 > 0.9 com prompts especializados

### 6.3 Integracao com ferramentas existentes (100% local)

- Ruff S rules ja cobrem a Camada 1 (hooks existentes)
- Semgrep local no quality-gates cobre a Camada 2
- Agent de review cobre a Camada 3
- Camada 4 (CI) e opcional — funciona em qualquer CI (GitLab, GitHub, Jenkins)

### 6.4 Dois agents posssiveis

1. **security-reviewer**: foca em padroes de vulnerabilidade (CWE-based)
2. **bug-reviewer**: foca em padroes de bugs comuns (null deref, leaks, off-by-one, race conditions)

Ou um unico agent com secoes para ambos.

---

## Fontes

- [One Bug, Hundreds Behind: LLMs for Large-Scale Bug Discovery](https://arxiv.org/abs/2510.14036)
- [IRIS: LLM-Assisted Static Analysis](https://arxiv.org/abs/2405.17238)
- [Can LLMs Find Bugs in Code?](https://arxiv.org/abs/2508.16419)
- [ZeroFalse: Improving Precision with LLMs](https://arxiv.org/abs/2510.02534)
- [Sifting the Noise: LLM Agents in Vulnerability FP Filtering](https://arxiv.org/abs/2601.22952)
- [Datadog: Using LLMs to Filter False Positives](https://www.datadoghq.com/blog/using-llms-to-filter-out-false-positives/)
- [NCC Group: AI vs Traditional Static Analysis](https://www.nccgroup.com/research/comparing-ai-against-traditional-static-analysis-tools-to-highlight-buffer-overflows/)
- [Anthropic: Claude Code Security Review Action](https://github.com/anthropics/claude-code-security-review)
- [Semgrep MCP Server](https://github.com/semgrep/mcp)
- [simple_semgrepAI (Semgrep + LLM)](https://github.com/hardw00t/simple_semgrepAI)
- [Semgrep Assistant (96% agreement)](https://semgrep.dev/blog/2025/building-an-appsec-ai-that-security-researchers-agree-with-96-of-the-time/)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills.md)
- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents.md)
