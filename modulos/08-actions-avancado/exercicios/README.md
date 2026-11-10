# 🏋️ Exercícios — Módulo 08

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 08        # todos do módulo
./ferramentas/corrigir.sh 08 01     # só o exercício 01
```

Os exercícios treinam matriz, ação composta e workflow reutilizável — validados como dados e pelo actionlint.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Uma matriz com exclusão e inclusão · `01-matriz.sh`
Crie `.github/workflows/matriz.yml` (com `on: [push, pull_request]` e `permissions: {contents: read}`) com o job `testes`:
- `strategy.fail-fast: false`;
- `strategy.matrix.os`: `[ubuntu-latest, windows-latest]` e `strategy.matrix.node`: `[20, 22, 24]` (números);
- `exclude` da combinação `windows-latest` + `20`;
- `include` acrescentando `experimental: true` à combinação `ubuntu-latest` + `24`;
- `runs-on: ${{ matrix.os }}` e `continue-on-error: ${{ matrix.experimental == true }}`;
- steps: checkout fixado por SHA e `actions/setup-node` fixado por SHA (pode usar `actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1 # v7.1.0`) com `node-version: ${{ matrix.node }}`.

O corretor calcula a expansão: devem sair **5 jobs**.

### 02 — Uma ação composta com entrada e saída · `02-acao-composta.sh`
Crie `.github/actions/saudacao/action.yml`:
- `name` e `description` (quaisquer);
- input `nome` com `required: true`;
- output `mensagem` com `value: ${{ steps.gerar.outputs.mensagem }}`;
- `runs.using: composite` com um step de `id: gerar`, `shell: bash`, que recebe o nome por `env` (`NOME: ${{ inputs.nome }}`) e escreve `mensagem=Olá, <nome>` em `$GITHUB_OUTPUT`.

O corretor **executa** o `run:` do seu step com `NOME=Ana` e confere a saída `mensagem=Olá, Ana`.

### 03 — Workflow reutilizável e quem o chama · `03-workflow-reutilizavel.sh`
Crie **dois** workflows:

**`.github/workflows/testes-reutilizavel.yml`**
- `on.workflow_call.inputs.versao-node`: `type: string`, `required: false`, `default: "22"`;
- `permissions: {contents: read}`;
- um job `testes` (`ubuntu-latest`) com checkout fixado por SHA e `actions/setup-node` fixado por SHA usando `node-version: ${{ inputs.versao-node }}`.

**`.github/workflows/ci.yml`**
- `on: [push, pull_request]` e `permissions: {contents: read}`;
- um job `testes` que **chama** o reutilizável: `uses: ./.github/workflows/testes-reutilizavel.yml` com `with.versao-node: "24"`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
