# 🏋️ Exercícios — Módulo 10

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 10        # todos do módulo
./ferramentas/corrigir.sh 10 01     # só o exercício 01
```

Os exercícios treinam a configuração do Dependabot, um detector de ações não fixadas e um workflow imune a injeção.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Dependabot com grupos e cooldown · `01-dependabot-yml.sh`
Crie `.github/dependabot.yml` com `version: 2` e duas entradas em `updates`:

1. `package-ecosystem: github-actions`, `directory: /`, `schedule.interval: weekly` e um grupo `acoes` com `patterns: ["*"]`;
2. `package-ecosystem: npm`, `directory: /`, `schedule.interval: weekly`, `open-pull-requests-limit: 5`, `cooldown.default-days: 7` e um grupo `dev` com `dependency-type: development`.

### 02 — Detector de ações não fixadas · `02-acoes-sem-sha.sh`
O script recebe uma pasta (padrão: `.github/workflows`) e examina todos os `*.yml` e `*.yaml` dela. Para cada linha com `uses:` cuja referência **não** seja um SHA de 40 caracteres hexadecimais, imprima:
```
ARQUIVO:LINHA: ACAO@REF
```
- ignore ações locais (`./…`) e imagens (`docker://…`);
- aceite aspas e comentários: `uses: "actions/cache@v6" # cache` → `actions/cache@v6`;
- `- uses:` (início de step) e `uses:` (continuação) contam igual;
- uma referência sem `@` também é problema: imprima-a como está.

Saia com **1** se encontrou algo, **0** se tudo está fixado. Pasta inexistente → **2**.

### 03 — Boas-vindas sem injeção · `03-workflow-sem-injecao.sh`
Crie `.github/workflows/boas-vindas.yml`, disparado em `issues` do tipo `opened`, que comenta no issue novo agradecendo o autor e citando o título. Requisitos de segurança:

- `permissions: {}` no **topo** (nada) e, no job, **apenas** `issues: write`;
- **nenhum** `run:` pode conter `${{` — título, número, autor, repositório e token chegam por `env:`;
- o comentário é feito com `gh issue comment "$NUMERO" -R "$REPO" --body "…$TITULO…"`, com `GH_TOKEN: ${{ github.token }}` no `env`;
- **não** use `pull_request_target`.

O corretor confere a estrutura, roda o actionlint e **executa o seu `run:`** com um título malicioso para provar que nenhum comando extra roda.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
