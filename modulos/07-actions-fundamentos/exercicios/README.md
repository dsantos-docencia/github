# 🏋️ Exercícios — Módulo 07

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 07        # todos do módulo
./ferramentas/corrigir.sh 07 01     # só o exercício 01
```

Os exercícios treinam escrever workflows corretos e seguros, e scripts que conversam com o runner.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Um workflow de CI correto · `01-workflow-ci.sh`
Crie `.github/workflows/ci.yml` que:
- tenha `name: CI`;
- dispare em **push na `main`** (`on.push.branches: [main]`) e em **qualquer `pull_request`**;
- declare `permissions` com `contents: read` (no nível do workflow);
- tenha um job `testes` com `runs-on: ubuntu-latest` e `timeout-minutes` de **no máximo 15**;
- primeiro step: `actions/checkout` **fixado por SHA de 40 caracteres** (pode usar `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`);
- um step que rode `./testes.sh`.

O corretor também passa o arquivo pelo **actionlint** (quando instalado).

### 02 — Um step que conversa com o runner · `02-step-de-versao.sh`
Escreva um script para ser usado como step. Ele lê a versão do arquivo `VERSION` (pasta atual) e:

- se a versão **não** for SemVer (`X.Y.Z` com sufixo opcional `-algo`), imprime `::error file=VERSION::versão inválida: <valor>` e sai com **1**;
- senão, acrescenta ao arquivo `$GITHUB_OUTPUT` as linhas `versao=<valor>` e `prerelease=true` (se tiver `-`) ou `prerelease=false`;
- e acrescenta ao `$GITHUB_STEP_SUMMARY` a linha `### Versão <valor>`.

Use `>>` (acrescentar): outros steps também escrevem nesses arquivos. Se `VERSION` não existir, trate como inválido. O corretor cria arquivos temporários e define as duas variáveis, como o runner faz.

### 03 — Manual, agendado e à prova de injeção · `03-workflow-agendado.sh`
Crie `.github/workflows/relatorio.yml`:
- `on.schedule` com **um** cron que rode **toda segunda às 08:00 de Brasília** (lembre: o cron é em **UTC**, e Brasília é UTC−3);
- `on.workflow_dispatch` com o input `dias` de `type: number` e `default: 7`;
- `permissions` no topo com `contents: read`;
- um job com `runs-on: ubuntu-latest` e um step que use o número de dias.

Regra de segurança: **nenhum** `run:` pode conter `${{` — passe o valor por `env:` (ex.: `DIAS: ${{ inputs.dias || 7 }}`) e use `"$DIAS"` no script.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
