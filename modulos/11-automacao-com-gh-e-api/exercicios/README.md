# 🏋️ Exercícios — Módulo 11

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 11        # todos do módulo
./ferramentas/corrigir.sh 11 01     # só o exercício 01
```

Os exercícios treinam verificação de webhooks, composição de chamadas ao `gh` e paginação.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Verificador de assinatura de webhook · `01-verificar-webhook.sh`
O script recebe `SEGREDO ARQUIVO_DO_CORPO ASSINATURA` e confere se `ASSINATURA` (no formato do cabeçalho `X-Hub-Signature-256`, ou seja, `sha256=<64 hex>`) é o HMAC-SHA256 do conteúdo **exato** do arquivo com o segredo.

- válida → imprime `válida` e sai com **0**;
- inválida → imprime `inválida` em stderr e sai com **1**;
- assinatura sem o prefixo `sha256=` → `formato inválido` em stderr e saída **1**;
- faltando argumento ou arquivo inexistente → saída **2**.

Dica: `openssl dgst -sha256 -hmac "$SEGREDO" < arquivo` — e cuidado para não alterar o corpo (nada de `echo` acrescentando `\n`).

### 02 — Um comando novo para o gh · `02-resumo-do-repo.sh`
Escreva o que seria a extensão `gh resumo`: recebe `dono/repo` e imprime **uma linha**:
```
aluno/laboratorio: 4 issues abertas, 3 PRs abertos
```
usando duas chamadas:
- `gh issue list -R REPO --state open --limit 1000 --json number --jq length`
- `gh pr list -R REPO --state open --limit 1000 --json number --jq length`

Sem argumento, tente descobrir o repositório da pasta atual com `gh repo view --json nameWithOwner --jq .nameWithOwner`; se isso falhar, mensagem em stderr e saída **2**.

(Para virar extensão de verdade: salve como `gh-resumo/gh-resumo`, dê `chmod +x` e rode `gh extension install .` dentro da pasta.)

### 03 — Todos os repositórios ativos de uma organização · `03-repos-ativos-da-org.sh`
O script recebe o nome de uma organização e lista, **um por linha e em ordem alfabética**, o `full_name` dos repositórios **não arquivados** — percorrendo **todas** as páginas:

```bash
gh api --paginate "orgs/ORG/repos?per_page=100" --jq '...'
```

No final, uma linha `total: N`. Com os dados de exemplo (3 repositórios, 1 arquivado):
```
aluno/laboratorio
aluno/site-pessoal
total: 2
```
Sem argumento → saída **2**.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
