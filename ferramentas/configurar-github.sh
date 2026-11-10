#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · ferramentas/configurar-github.sh
#  Governança do repositório como CÓDIGO: rulesets + recursos de segurança.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  POR QUE EXISTE
#    Configurações administrativas exigem o SEU acesso de admin — não podem ser
#    aplicadas de dentro de uma sessão automatizada. Este script aplica tudo de
#    uma vez com o gh já autenticado, e é idempotente: rodar de novo ATUALIZA
#    os rulesets em vez de duplicá-los (a técnica do exercício 06.02).
#
#  USO
#    ./ferramentas/configurar-github.sh DONO/REPO [NOME-DO-CHECK-DE-CI]
#    ./ferramentas/configurar-github.sh dsantos-docencia/github verificar
#
#  O QUE APLICA
#    Ruleset "proteger-main" (branch padrão):
#      PR obrigatório com 1 aprovação + revisão do CODEOWNERS; aprovações
#      descartadas a cada push; conversas resolvidas; check de CI obrigatório e
#      branch atualizada; histórico linear; sem force push; sem exclusão.
#      Bypass: papel Admin — você ainda consegue mesclar seus próprios PRs.
#    Ruleset "proteger-tags" (refs/tags/v*): ninguém apaga nem move uma versão.
#    Segurança: alertas e correções do Dependabot, secret scanning + push
#      protection, relato privado de vulnerabilidade e "exigir ações por SHA".
# ============================================================================
set -euo pipefail

repo="${1:-}"
check_ci="${2:-verificar}"
[[ "$repo" == */* ]] || { echo "uso: $0 DONO/REPO [nome-do-check-de-ci]" >&2; exit 2; }
command -v gh >/dev/null || { echo "erro: instale o GitHub CLI (gh) e rode 'gh auth login'" >&2; exit 1; }
command -v jq >/dev/null || { echo "erro: instale o jq" >&2; exit 1; }

echo "➤ Repositório: $repo   check obrigatório: $check_ci"

# aplicar_ruleset JSON — cria (POST) ou atualiza (PUT) pelo nome.
aplicar_ruleset() {
    local json="$1" nome id
    nome="$(jq -r .name <<<"$json")"
    id="$(gh api "repos/$repo/rulesets" | jq -r --arg n "$nome" '.[] | select(.name == $n) | .id' | head -1)"
    if [[ -n "$id" ]]; then
        gh api -X PUT "repos/$repo/rulesets/$id" --input - <<<"$json" >/dev/null && echo "   ✔ ruleset '$nome' atualizado"
    else
        gh api -X POST "repos/$repo/rulesets" --input - <<<"$json" >/dev/null && echo "   ✔ ruleset '$nome' criado"
    fi
}

echo "① Ruleset da branch padrão"
aplicar_ruleset "$(jq -n --arg ci "$check_ci" '{
  name: "proteger-main", target: "branch", enforcement: "active",
  conditions: { ref_name: { include: ["~DEFAULT_BRANCH"], exclude: [] } },
  bypass_actors: [ { actor_id: 5, actor_type: "RepositoryRole", bypass_mode: "always" } ],
  rules: [
    { type: "deletion" },
    { type: "non_fast_forward" },
    { type: "required_linear_history" },
    { type: "pull_request", parameters: {
        required_approving_review_count: 1, dismiss_stale_reviews_on_push: true,
        require_code_owner_review: true, require_last_push_approval: false,
        required_review_thread_resolution: true } },
    { type: "required_status_checks", parameters: {
        strict_required_status_checks_policy: true,
        required_status_checks: [ { context: $ci } ] } }
  ] }')"

echo "② Ruleset das tags de versão"
aplicar_ruleset '{
  "name": "proteger-tags", "target": "tag", "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/tags/v*"], "exclude": [] } },
  "bypass_actors": [ { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" } ],
  "rules": [ { "type": "deletion" }, { "type": "update" }, { "type": "non_fast_forward" } ] }'

echo "③ Dependabot: alertas e correções automáticas"
gh api -X PUT "repos/$repo/vulnerability-alerts" >/dev/null && echo "   ✔ alertas ligados"
gh api -X PUT "repos/$repo/automated-security-fixes" >/dev/null && echo "   ✔ correções ligadas"

echo "④ Secret scanning + push protection"
gh api -X PATCH "repos/$repo" --input - >/dev/null <<'JSON'
{ "security_and_analysis": {
    "secret_scanning": { "status": "enabled" },
    "secret_scanning_push_protection": { "status": "enabled" } } }
JSON
echo "   ✔ ligados"

echo "⑤ Relato privado de vulnerabilidade"
gh api -X PUT "repos/$repo/private-vulnerability-reporting" >/dev/null && echo "   ✔ ligado"

echo "⑥ Actions: exigir ações fixadas por SHA"
gh api -X PUT "repos/$repo/actions/permissions" -F enabled=true -f allowed_actions=all \
    -F sha_pinning_required=true >/dev/null && echo "   ✔ política aplicada"

cat <<FIM

✅ Pronto! Confira em:
   https://github.com/$repo/settings/rules              (rulesets)
   https://github.com/$repo/settings/security_analysis  (segurança)
   https://github.com/$repo/settings/actions            (política de ações)

Observações:
  • Rode DEPOIS que o check "$check_ci" tiver aparecido ao menos uma vez — senão
    o PR fica esperando um check que o GitHub ainda não conhece.
  • Rulesets em repositórios PRIVADOS exigem plano Pro/Team; em públicos, Free basta.
FIM
