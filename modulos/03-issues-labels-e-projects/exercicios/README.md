# 🏋️ Exercícios — Módulo 03

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 03        # todos do módulo
./ferramentas/corrigir.sh 03 01     # só o exercício 01
```

Os exercícios treinam issue forms, labels em lote e triagem com `--json`/`jq`.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Um formulário de bug que não aceita relato pela metade · `01-issue-form.sh`
Crie dois arquivos:

**`.github/ISSUE_TEMPLATE/bug.yml`** com:
- `name: Relatar um bug`, uma `description` (qualquer texto) e `labels: ["bug"]`;
- em `body`, pelo menos estes campos (nesta ordem, outros podem vir antes/depois):
  1. `textarea` com `id: passos`, um `attributes.label` e **`validations.required: true`**;
  2. `dropdown` com `id: gravidade` e `options` exatamente `Baixa`, `Média`, `Alta`;
  3. `textarea` com `id: logs` e `attributes.render: shell` (o GitHub formata o conteúdo como código).

**`.github/ISSUE_TEMPLATE/config.yml`** com `blank_issues_enabled: false`.

### 02 — Labels padronizados em lote · `02-labels-em-lote.sh`
O script recebe um arquivo TSV (`$1`) e um repositório (`$2`). Cada linha do arquivo tem `nome<TAB>cor<TAB>descrição`; linhas vazias e linhas que começam com `#` devem ser ignoradas.

Para cada label, chame:
```bash
gh label create "NOME" --color "COR" --description "DESCRIÇÃO" --force -R "REPO"
```
(`--force` atualiza se já existir — o script pode rodar várias vezes sem erro: isso é **idempotência**.)

No final, imprima `N labels sincronizados`. Arquivo inexistente → mensagem em stderr e saída **1**.

### 03 — A fila de triagem · `03-fila-de-triagem.sh`
O script recebe `dono/repo` em `$1`. Com **uma** chamada
`gh issue list -R "$1" --state open --limit 200 --json number,title,assignees,labels`,
imprima os issues **sem responsável**, do **menor para o maior número**, uma linha cada:

```
#9 Documentar a API de pedidos [documentação, good first issue]
#10 Botão de login desalinhado no celular [bug]
#11 Adicionar modo escuro [melhoria]
```

Issue sem labels termina com `[]`. Se ninguém estiver sem dono, imprima `fila vazia 🎉`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
