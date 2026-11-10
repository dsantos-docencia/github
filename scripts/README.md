# 🧰 Scripts reais

Ferramentas prontas para o dia a dia com o GitHub — cada uma com **testes** (rodados contra o `gh` simulado pela etapa 6 de `./ferramentas/verificar-tudo.sh`) e comentários explicando as decisões. Tudo o que **apaga** algo **simula por padrão** e só age com `--aplicar`.

Requisitos: `gh` autenticado (`gh auth login`), `jq` e Bash 4+.

## Dia a dia

| Script | O que faz | Exemplo |
|---|---|---|
| [`clonar-todos.sh`](dia-a-dia/clonar-todos.sh) | clona os repositórios de um usuário/organização ou atualiza os que já existem (`pull --ff-only`) | `./clonar-todos.sh minha-org ~/codigo` |
| [`minha-fila.sh`](dia-a-dia/minha-fila.sh) | revisões pedidas a você, seus PRs abertos e issues atribuídos | `./minha-fila.sh --org minha-org` |
| [`sincronizar-labels.sh`](dia-a-dia/sincronizar-labels.sh) | aplica um conjunto padrão de labels; lista (ou remove, com `--aplicar`) os que sobram | `./sincronizar-labels.sh aluno/loja --remover-extras` |

## Actions

| Script | O que faz | Exemplo |
|---|---|---|
| [`disparar-e-acompanhar.sh`](actions/disparar-e-acompanhar.sh) | dispara um `workflow_dispatch` e acompanha até o fim, saindo com o resultado | `./disparar-e-acompanhar.sh deploy.yml -f ambiente=homologacao` |
| [`limpar-caches.sh`](actions/limpar-caches.sh) | encontra caches de PRs e sem uso há N dias | `./limpar-caches.sh aluno/loja --dias 14 --aplicar` |

## Auditoria

| Script | O que faz | Exemplo |
|---|---|---|
| [`auditar-workflows.sh`](auditoria/auditar-workflows.sh) | `pull_request_target`, injeção por `${{ }}` em `run:`, ações sem SHA, falta de `permissions:` | `./auditar-workflows.sh .github/workflows` |
| [`revisar-acessos.sh`](auditoria/revisar-acessos.sh) | colaboradores por papel, alerta de admins demais | `./revisar-acessos.sh aluno/loja --json` |

## Release e backup

| Script | O que faz | Exemplo |
|---|---|---|
| [`notas-da-versao.sh`](release/notas-da-versao.sh) | gera as notas de uma versão pela API, para revisar antes de publicar | `./notas-da-versao.sh aluno/loja v1.3.0 v1.2.0 --saida NOTAS.md` |
| [`exportar-issues.sh`](backup/exportar-issues.sh) | exporta todos os issues para JSON + índice Markdown (issues não vêm no `git clone`!) | `./exportar-issues.sh aluno/loja` |

## Da comunidade

Scripts enviados por alunos e alunas ficam em [`comunidade/`](comunidade/), com crédito. Quer contribuir? Abra um issue com o template **“📜 Enviar um script para a comunidade”**.

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · código PolyForm-NC</sub>
