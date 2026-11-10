# Cheat sheet do GitHub Actions

## Esqueleto comentado

```yaml
name: CI                                  # nome na aba Actions
run-name: CI de ${{ github.ref_name }}    # nome de cada execução
on: [push, pull_request]                  # ou um mapa com filtros (abaixo)
permissions: { contents: read }           # SEMPRE declare
concurrency: { group: ci-${{ github.ref }}, cancel-in-progress: true }
env: { NODE_ENV: test }                   # variáveis para todos os jobs
defaults: { run: { shell: bash } }
jobs:
  testes:
    name: Testes (${{ matrix.node }})
    runs-on: ubuntu-latest
    timeout-minutes: 10
    needs: []                             # dependências entre jobs
    if: github.event_name != 'schedule'
    environment: homologacao              # regras e segredos do ambiente
    strategy: { fail-fast: false, matrix: { node: [22, 24] } }
    outputs: { versao: "${{ steps.v.outputs.versao }}" }
    services: { db: { image: postgres:17, env: { POSTGRES_PASSWORD: teste } } }
    steps:
      - uses: actions/checkout@<sha> # vX.Y.Z
        with: { persist-credentials: false }
      - id: v
        name: Versão
        run: echo "versao=1.0.0" >> "$GITHUB_OUTPUT"
        working-directory: app
        continue-on-error: false
        env: { CAMINHO: dist }
```

## Eventos mais usados

| Evento | Filtros / tipos | Observação |
|---|---|---|
| `push` | `branches`, `branches-ignore`, `tags`, `paths`, `paths-ignore` | |
| `pull_request` | `types: [opened, synchronize, reopened, labeled, ready_for_review]`, `branches`, `paths` | de forks: sem segredos e token só leitura |
| `pull_request_target` | idem | ⚠️ contexto privilegiado; bloqueado por padrão em públicos desde 02/12/2026 (Módulo 10) |
| `merge_group` | | obrigatório com merge queue |
| `workflow_dispatch` | `inputs` (`string`, `number`, `boolean`, `choice`, `environment`) | manual / `gh workflow run` |
| `workflow_call` | `inputs`, `secrets`, `outputs` | workflow reutilizável |
| `schedule` | `cron` (UTC) | só na branch padrão |
| `release` | `types: [published]` | |
| `issues` / `issue_comment` | `types: [opened, labeled, created]` | |
| `workflow_run` | `workflows: [CI]`, `types: [completed]` | encadear workflows |

## Contextos

| Contexto | Exemplos |
|---|---|
| `github` | `ref`, `ref_name`, `sha`, `event_name`, `actor`, `repository`, `run_id`, `run_number`, `server_url`, `event.*`, `token` |
| `env` / `vars` / `secrets` | `env.NODE_ENV`, `vars.AMBIENTE`, `secrets.NPM_TOKEN`, `secrets.GITHUB_TOKEN` |
| `inputs` | `inputs.ambiente` |
| `job` / `steps` / `needs` | `job.status`, `steps.v.outputs.versao`, `steps.v.outcome`, `needs.build.outputs.versao`, `needs.build.result` |
| `runner` / `matrix` / `strategy` | `runner.os`, `runner.temp`, `matrix.node`, `strategy.job-index` |

## Funções em expressões

| Função | Exemplo |
|---|---|
| `contains(a, b)` | `contains(github.event.pull_request.labels.*.name, 'deploy')` |
| `startsWith` / `endsWith` | `startsWith(github.ref, 'refs/tags/v')` |
| `format` | `format('{0}-{1}', runner.os, matrix.node)` |
| `join` / `toJSON` / `fromJSON` | `fromJSON(needs.setup.outputs.matriz)` (matriz dinâmica) |
| `hashFiles` | `hashFiles('**/package-lock.json')` |
| `success()` / `failure()` / `always()` / `cancelled()` | `if: failure()` |
| operadores | `==` `!=` `&&` `\|\|` `!` · `a \|\| 'padrão'` |

## Arquivos especiais e comandos

| O quê | Como |
|---|---|
| saída do step | `echo "chave=valor" >> "$GITHUB_OUTPUT"` |
| saída multilinha | `{ echo 'texto<<FIM'; cat arquivo; echo FIM; } >> "$GITHUB_OUTPUT"` |
| variável p/ próximos steps | `echo "NOME=valor" >> "$GITHUB_ENV"` |
| PATH p/ próximos steps | `echo "$HOME/bin" >> "$GITHUB_PATH"` |
| resumo em Markdown | `echo "### Feito ✅" >> "$GITHUB_STEP_SUMMARY"` |
| anotações | `::error file=a.js,line=3::msg` · `::warning::msg` · `::notice::msg` |
| agrupar log | `::group::Título` … `::endgroup::` |
| mascarar valor | `::add-mask::$VALOR` |

## Permissões do `GITHUB_TOKEN`

`actions` · `attestations` · `checks` · `contents` · `deployments` · `discussions` · `id-token` · `issues` · `packages` · `pages` · `pull-requests` · `security-events` · `statuses` — cada uma `read`, `write` ou `none`. `permissions: {}` = nenhuma.

## Ações oficiais comuns — fixadas por SHA (novembro de 2026)

| Ação | Linha pronta |
|---|---|
| checkout | `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1` |
| setup-node | `actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1 # v7.1.0` |
| setup-python | `actions/setup-python@6d4fd22b20465ccc0f7354476588e8df7c9ca0e0 # v7.1.0` |
| cache | `actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9 # v6.1.0` |
| upload-artifact | `actions/upload-artifact@cf430e030ddbb5b0abf93d22962f4752f3646cd9 # v7.0.2` |
| download-artifact | `actions/download-artifact@9000827ccba6bdab643e8b6fd33ac0654aef8333 # v8.0.2` |
| configure-pages | `actions/configure-pages@45bfe0192ca1faeb007ade9deae92b16b8254a0d # v6.0.0` |
| upload-pages-artifact | `actions/upload-pages-artifact@fc324d3547104276b827a68afc52ff2a11cc49c9 # v5.0.0` |
| deploy-pages | `actions/deploy-pages@368f82528645a54fb793d4d04e342629a3f51346 # v5.0.1` |
| attest-build-provenance | `actions/attest-build-provenance@4d101475d8b20a2381f78447822ac1eab6504dd8 # v4.2.2` |
| codeql (init/analyze) | `github/codeql-action/init@33d7b85da1a04171e211befe2c739303b9a4c066 # v4.39.3` |
| docker login | `docker/login-action@8aa5831fb8d48d8f76594c7ddde61ae58019f550 # v4.8.0` |

> SHAs envelhecem: deixe o **Dependabot** (`package-ecosystem: github-actions`) atualizá-los, ou use `gh actions-lock`. Para conferir um SHA: `git ls-remote https://github.com/actions/checkout refs/tags/v7.0.1`.

## Ferramentas

`actionlint arquivo.yml` (validação) · `zizmor .github/workflows` (segurança) · `act -l` / `act push` (rodar local) · `gh actions-lock --verify` (lockfile)

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · CC BY-NC-SA 4.0</sub>
