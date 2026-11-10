# 🏋️ Exercícios — Módulo 06

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 06        # todos do módulo
./ferramentas/corrigir.sh 06 01     # só o exercício 01
```

Os exercícios tratam rulesets como código: escrever o JSON, aplicá-lo de forma idempotente e auditar uma branch.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Um ruleset completo em JSON · `01-ruleset-json.sh`
Crie o arquivo `ruleset-main.json` com:
- `name`: `proteger-main`; `target`: `branch`; `enforcement`: `active`;
- `conditions.ref_name.include`: `["~DEFAULT_BRANCH"]` e `exclude`: `[]`;
- `rules` contendo:
  - `deletion` e `non_fast_forward` (sem parâmetros);
  - `pull_request` com **todos** os 5 parâmetros que a API exige: `required_approving_review_count: 1`, `dismiss_stale_reviews_on_push: true`, `require_code_owner_review: true`, `require_last_push_approval: false`, `required_review_thread_resolution: true`;
  - `required_status_checks` com `strict_required_status_checks_policy: true` e `required_status_checks: [{"context": "verificar"}]`.

O arquivo precisa ser JSON válido (o corretor usa o `jq`).

### 02 — Aplicar um ruleset sem duplicar · `02-aplicar-ruleset.sh`
O script recebe `dono/repo` e o caminho de um arquivo de ruleset. Ele deve ser **idempotente**: rodar duas vezes não cria dois rulesets iguais.

1. arquivo inexistente ou JSON inválido → mensagem em stderr e saída **1**, sem chamar a API de escrita;
2. leia o `name` do arquivo;
3. procure um ruleset com esse nome: `gh api "repos/REPO/rulesets" --jq '.[] | select(.name=="NOME") | .id'`;
4. se existir → `gh api -X PUT "repos/REPO/rulesets/ID" --input ARQUIVO` e imprima `atualizado: NOME (ID)`;
5. se não existir → `gh api -X POST "repos/REPO/rulesets" --input ARQUIVO` e imprima `criado: NOME`.

(Dica: passe o nome ao `jq` com `--arg` em vez de colar dentro do filtro… mas o `--jq` do `gh` não aceita `--arg`. Alternativa segura: busque a lista e filtre com o `jq` local, `jq --arg n "$nome" '…'`.)

### 03 — Auditoria das regras de uma branch · `03-auditar-branch.sh`
O script recebe `dono/repo` e uma branch (padrão: `main`) e consulta **as regras ativas de fato** na branch:
```bash
gh api "repos/REPO/rules/branches/BRANCH"
```
A resposta é uma lista de objetos com `type`. Verifique, nesta ordem, os 4 tipos essenciais — `deletion`, `non_fast_forward`, `pull_request`, `required_status_checks` — imprimindo `✔ tipo` ou `✘ tipo`.

Saia com **0** se todos estiverem presentes, **1** se faltar algum. Com os dados de exemplo do simulador, falta `required_status_checks`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
