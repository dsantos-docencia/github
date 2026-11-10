# Glossário

| Termo | Significado |
|---|---|
| **Action** (ação) | pedaço reutilizável de automação usado com `uses:` num workflow |
| **Actions** (GitHub Actions) | o motor de automação/CI-CD do GitHub |
| **Admin / Maintain / Write / Triage / Read** | papéis de acesso a um repositório, do maior ao menor |
| **Advisory** (security advisory) | aviso de vulnerabilidade de um projeto; pode receber CVE |
| **Artefato** (artifact) | arquivo produzido por um workflow e guardado para download |
| **Atestação** (attestation) | prova assinada de que um arquivo foi gerado por certo workflow/commit |
| **Bypass** | permissão para ignorar um ruleset |
| **Cache** | cópia de dependências reaproveitada entre execuções |
| **CI / CD** | integração contínua (testar sempre) / entrega contínua (publicar sempre) |
| **CODEOWNERS** | arquivo que define donos (revisores automáticos) por caminho |
| **CodeQL** | motor de análise de código do GitHub (code scanning) |
| **Composite action** | ação feita de steps, em YAML |
| **Contexto** | objeto disponível em expressões: `github`, `env`, `secrets`, `matrix`… |
| **Cooldown** | espera configurada antes de o Dependabot adotar uma versão nova |
| **Dependabot** | robô que avisa e atualiza dependências |
| **Draft** (rascunho) | PR ou release ainda não pronto |
| **Environment** (ambiente) | alvo de deploy com regras (aprovação, espera) e segredos próprios |
| **Evento** | o que dispara um workflow (`push`, `pull_request`…) |
| **Fork** | cópia de um repositório na sua conta, ligada ao original |
| **GFM** | GitHub Flavored Markdown |
| **GHCR** | GitHub Container Registry (`ghcr.io`) |
| **GitHub App** | integração com identidade própria e permissões finas |
| **`GITHUB_TOKEN`** | token automático de cada execução do Actions |
| **Issue form** | template de issue em YAML, com campos obrigatórios |
| **Job** | conjunto de steps que roda numa máquina |
| **Lockfile de workflow** | `.github/workflows/actions.lock`: trava os commits de todas as ações usadas |
| **Matriz** (matrix) | um job multiplicado por combinações de valores |
| **Merge queue** | fila que testa PRs combinados antes de mesclar |
| **Milestone** | marco/entrega que agrupa issues e PRs |
| **OIDC** | token de identidade do workflow, trocado por credenciais temporárias na nuvem |
| **Pages** | hospedagem de sites estáticos do GitHub |
| **PAT** | personal access token (clássico `ghp_` ou fine-grained `github_pat_`) |
| **Permalink** | link fixado num commit |
| **Pull request (PR)** | pedido para integrar uma branch em outra, com revisão |
| **Push protection** | bloqueio de push que contém segredo |
| **Release** | página de uma versão, sobre uma tag, com notas e anexos |
| **Release imutável** | release cujos anexos e tag não podem mais ser alterados |
| **Reusable workflow** | workflow chamado por outro (`workflow_call`) |
| **Ruleset** | conjunto nomeado de regras para branches, tags ou pushes |
| **Runner** | a máquina que executa os jobs (hospedada ou self-hosted) |
| **SBOM** | lista de componentes de software (*software bill of materials*) |
| **Secret scanning** | varredura de segredos no repositório |
| **Step** | um passo de um job: `run:` ou `uses:` |
| **Template injection** | injeção de código via `${{ }}` dentro de `run:` |
| **Upstream** | o repositório original de um fork (ou a branch remota que uma local acompanha) |
| **Webhook** | chamada HTTP que o GitHub faz a um servidor seu a cada evento |
| **Workflow** | arquivo YAML em `.github/workflows/` que define uma automação |

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · CC BY-NC-SA 4.0</sub>
