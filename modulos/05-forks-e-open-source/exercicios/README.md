# 🏋️ Exercícios — Módulo 05

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 05        # todos do módulo
./ferramentas/corrigir.sh 05 01     # só o exercício 01
```

Os exercícios treinam a checagem dos arquivos de saúde da comunidade, a sincronização de forks e a licença via API.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Checklist de saúde da comunidade · `01-saude-da-comunidade.sh`
O script recebe uma pasta em `$1` (padrão: `.`) e verifica 7 itens. Cada arquivo pode estar na **raiz**, em **`docs/`** ou em **`.github/`** — como o GitHub aceita:

| Item | Aceita |
|---|---|
| `README` | `README.md` |
| `LICENSE` | `LICENSE` ou `LICENSE.md` |
| `CONTRIBUTING` | `CONTRIBUTING.md` |
| `CODE_OF_CONDUCT` | `CODE_OF_CONDUCT.md` |
| `SECURITY` | `SECURITY.md` |
| `ISSUE_TEMPLATE` | a **pasta** `ISSUE_TEMPLATE` |
| `PR_TEMPLATE` | `pull_request_template.md` ou `PULL_REQUEST_TEMPLATE.md` |

Para cada item imprima `✔ ITEM` ou `✘ ITEM` (nesta ordem) e, por último, `nota: N/7`. Saia com **0** se a nota for 7/7, senão **1**. Pasta inexistente → saída **2**.

### 02 — Sincronizar o fork com o original · `02-sincronizar-fork.sh`
Os testes criam `upstream.git` (o original), `fork.git` (seu fork) e o clone `meu-fork` (com `origin` = fork), e depois adicionam commits novos no original.

O script recebe a **URL do upstream** em `$1` e, dentro de `meu-fork`:
1. adiciona o remoto `upstream` com essa URL **se ainda não existir** (se existir, não falhe — o script precisa poder rodar de novo);
2. busca o upstream;
3. avança a `main` local **somente por avanço rápido** até `upstream/main`;
4. envia a `main` para o `origin`.

Termine imprimindo `fork sincronizado em <hash curto>`. Se a `main` do fork tiver commits próprios (não dá avanço rápido), o script deve **falhar** (saída ≠ 0) sem enviar nada.

### 03 — Licença oficial via API · `03-licenca-via-api.sh`
O script recebe `CHAVE ANO NOME` (ex.: `mit 2026 "Ana Dev"`) e cria o arquivo `LICENSE` com o texto oficial obtido por
```bash
gh api "licenses/CHAVE" --jq .body
```
substituindo os campos `[year]` pelo ano e `[fullname]` pelo nome. Faltando argumento → uso em stderr e saída **2**. Se a chamada ao `gh` falhar (licença inexistente), saia com **1** e **não** deixe um `LICENSE` vazio para trás.

> Atenção: o nome pode ter caracteres especiais para o `sed` (como `/` ou `&`). A substituição do próprio Bash evita o problema — **com a substituta entre aspas**: `"${texto//\[year\]/"$ano"}"`. Sem as aspas, no Bash 5.2+ um `&` na substituta vira “o trecho encontrado” (como no `sed`).

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
