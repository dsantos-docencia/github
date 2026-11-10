# Módulo 08 · GitHub Actions: avançado

> **Você vai sair daqui sabendo:** testar em várias versões e sistemas com **matriz**, acelerar com **cache**, passar arquivos entre jobs com **artefatos**, evitar execuções duplicadas com **concurrency**, proteger deploys com **ambientes**, eliminar repetição com **workflows reutilizáveis** e **ações compostas**, dar ao `GITHUB_TOKEN` só o necessário e trocar segredos de nuvem por **OIDC**.

⏱ 5–6 h · 🧪 [Laboratório (act)](../../laboratorio/#opção-d--rodando-workflows-localmente-com-act) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

O CI da loja funciona, mas: leva 9 minutos (reinstala tudo sempre), só testa no Linux com uma versão do Node, três repositórios copiam o mesmo YAML (e divergem), e o deploy para produção usa uma chave da nuvem guardada como segredo há dois anos. Este módulo resolve cada um desses problemas.

## 2. Matriz: um job, muitas combinações

```yaml
strategy:
  fail-fast: false                 # uma combinação falhar não cancela as outras
  max-parallel: 4
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [20, 22, 24]
    exclude:
      - os: windows-latest
        node: 20                   # remove uma combinação
    include:
      - os: ubuntu-latest
        node: 24
        experimental: true         # casa com uma combinação existente: só ACRESCENTA a chave
runs-on: ${{ matrix.os }}
continue-on-error: ${{ matrix.experimental == true }}
```

2 × 3 = 6 combinações, menos 1 excluída = **5 jobs**. O `include` acima não cria job novo: ele casa com `ubuntu-latest/24` e só adiciona `experimental`. Um `include` que **não** casa com nenhuma combinação vira um job extra. O exemplo 01 calcula isso passo a passo.

## 3. Cache × artefatos

| | **Cache** (`actions/cache`, ou `cache:` nos `setup-*`) | **Artefato** (`upload-artifact` / `download-artifact`) |
|---|---|---|
| Para quê | acelerar: dependências que **podem** ser baixadas de novo | entregar: arquivos que um job **produz** para outro job ou para pessoas |
| Chave | `key:` exata + `restore-keys:` (prefixos de reserva) | nome do artefato |
| Se faltar | o job só fica mais lento | o job seguinte falha |
| Duração | removido se não usado por 7 dias; limite por repositório | retenção configurável (`retention-days`) |

```yaml
- uses: actions/cache@<sha>
  with:
    path: ~/.npm
    key: npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
    restore-keys: npm-${{ runner.os }}-     # se a exata não existir, aproveita a mais recente com este prefixo
```

> 🧠 A chave inclui o **hash do lockfile**: mudou a dependência, muda a chave, o cache é refeito. O `restore-keys` evita começar do zero. O exemplo 03 mostra as chaves mudando.

## 4. Controle de execução

```yaml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: true           # push novo cancela o anterior (ótimo para CI; cuidado em deploy!)
jobs:
  build:   { runs-on: ubuntu-latest, outputs: { versao: "${{ steps.v.outputs.versao }}" }, steps: [...] }
  deploy:
    needs: build                     # espera o build
    if: github.ref == 'refs/heads/main'
    environment:
      name: producao                 # regras do ambiente: revisores, espera, branches permitidas
      url: https://loja.exemplo.dev
```

**Ambientes** (*Settings → Environments*) dão a um job: **aprovação obrigatória** de pessoas, **tempo de espera**, restrição de **quais branches** podem implantar e **segredos próprios** — o segredo de produção só existe para jobs do ambiente `producao`.

## 5. Reutilizando: workflow reutilizável × ação composta

| | **Workflow reutilizável** (`on: workflow_call`) | **Ação composta** (`runs.using: composite`) |
|---|---|---|
| Unidade | **jobs** inteiros (com `runs-on`, ambientes, matriz) | **steps** dentro de um job |
| Como chamar | `jobs.x.uses: dono/repo/.github/workflows/w.yml@<sha>` | `steps[].uses: dono/repo/caminho@<sha>` ou `./.github/actions/nome` |
| Segredos | `secrets:` explícitos ou `secrets: inherit` | via `inputs` |
| Logs | cada job aparece separado | aparece como um step só |
| Bom para | “o pipeline padrão da empresa” | “instalar e configurar a ferramenta X” |

```yaml
# .github/workflows/testes-reutilizavel.yml
on:
  workflow_call:
    inputs:
      versao-node: { type: string, required: false, default: "22" }
    outputs:
      resultado: { value: "${{ jobs.testes.outputs.resultado }}" }

# .github/workflows/ci.yml (quem chama)
jobs:
  testes:
    uses: ./.github/workflows/testes-reutilizavel.yml
    with:
      versao-node: "24"
```

```yaml
# .github/actions/saudacao/action.yml
name: Saudação
inputs:
  nome: { required: true }
outputs:
  mensagem: { value: "${{ steps.gerar.outputs.mensagem }}" }
runs:
  using: composite
  steps:
    - id: gerar
      shell: bash                    # em ação composta, shell é OBRIGATÓRIO em cada run
      env: { NOME: "${{ inputs.nome }}" }
      run: echo "mensagem=Olá, $NOME" >> "$GITHUB_OUTPUT"
```

## 6. O `GITHUB_TOKEN` e as permissões

Cada execução recebe um token automático (`ghs_…`) que **expira ao fim do job**. O que ele pode fazer é decidido por `permissions:` — declare sempre, no topo e/ou por job:

```yaml
permissions: {}                 # topo: nada
jobs:
  rotular:
    permissions:
      issues: write             # só este job, só issues
```

| Escopo comum | `read` permite | `write` permite |
|---|---|---|
| `contents` | clonar | push, criar release |
| `issues` / `pull-requests` | ler | comentar, rotular |
| `packages` | baixar pacote | publicar no GHCR |
| `pages` | — | publicar no Pages |
| `id-token` | — | pedir token **OIDC** |
| `attestations` | — | criar atestações de proveniência |

## 7. OIDC: deploy na nuvem sem segredo guardado

Em vez de guardar uma chave de acesso da AWS/Azure/GCP como segredo (que vaza, que ninguém troca), o job pede ao GitHub um **token OIDC** assinado dizendo “sou o workflow X do repo Y, na branch main”. A nuvem, configurada para confiar no GitHub, troca esse token por credenciais **temporárias**:

```yaml
permissions:
  id-token: write
  contents: read
steps:
  - uses: aws-actions/configure-aws-credentials@<sha>
    with:
      role-to-assume: arn:aws:iam::123456789012:role/deploy-loja
      aws-region: sa-east-1
```

## 8. Runners auto-hospedados e depuração

- **Self-hosted**: máquina sua (GPU, rede interna, hardware específico). **Nunca** em repositório público. Prefira runners **efêmeros** (um job e descarta).
- **Depurar**: crie o segredo `ACTIONS_STEP_DEBUG=true` para logs detalhados; *Re-run jobs → Enable debug logging*; `gh run view --log-failed`.
- **Iterar rápido**: `act` localmente + `actionlint` antes do push.

## 9. Armadilhas comuns

- **`cancel-in-progress: true` no deploy** — cancelar um deploy no meio pode deixar produção pela metade. Use só no CI.
- **Cache com chave fixa** (`key: npm`) — nunca atualiza; ou cache de `node_modules/` inteiro entre sistemas diferentes.
- **Artefato com segredo dentro** (um `.env` no build) — artefatos podem ser baixados por quem tem leitura no repositório.
- **`secrets: inherit` em workflow de terceiros** — você entrega **todos** os seus segredos a código que não controla.
- **Esquecer `shell:` em ação composta** — erro “Required property is missing: shell”.

## 📚 Fontes oficiais

- Usar matriz: <https://docs.github.com/pt/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations>
- Cache de dependências: <https://docs.github.com/pt/actions/reference/workflows-and-actions/dependency-caching>
- Artefatos: <https://docs.github.com/pt/actions/tutorials/store-and-share-data>
- Concorrência: <https://docs.github.com/pt/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency>
- Ambientes de implantação: <https://docs.github.com/pt/actions/reference/workflows-and-actions/deployments-and-environments>
- Reutilizar workflows: <https://docs.github.com/pt/actions/how-tos/reuse-automations/reuse-workflows>
- Criar uma ação composta: <https://docs.github.com/pt/actions/tutorials/create-actions/create-a-composite-action>
- Permissões do GITHUB_TOKEN: <https://docs.github.com/pt/actions/concepts/security/github_token>
- OpenID Connect: <https://docs.github.com/pt/actions/concepts/security/openid-connect>
- Runners auto-hospedados: <https://docs.github.com/pt/actions/concepts/runners/self-hosted-runners>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
