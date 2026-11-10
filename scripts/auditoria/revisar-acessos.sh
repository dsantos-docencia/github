#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/auditoria/revisar-acessos.sh
#  Revisão de acessos: quem tem qual papel num repositório (menor privilégio).
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   revisar-acessos.sh DONO/REPO [--json]
#  Lista colaboradores por papel e destaca o que merece uma pergunta:
#  mais de um admin, e quem só tem acesso por convite direto (não por time).
# ============================================================================
set -euo pipefail

repo="${1:-}"
[[ "$repo" == */* ]] || { echo "uso: $0 DONO/REPO [--json]" >&2; exit 2; }
dados="$(gh api --paginate "repos/$repo/collaborators?per_page=100" | jq -s 'add // []')"

if [[ "${2:-}" == "--json" ]]; then
    jq '{total: length, por_papel: (group_by(.role_name) | map({(.[0].role_name): map(.login)}) | add // {})}' <<<"$dados"
    exit 0
fi

echo "Acessos em $repo"
for papel in admin maintain write triage read; do
    pessoas="$(jq -r --arg p "$papel" '[.[] | select(.role_name == $p) | .login] | join(", ")' <<<"$dados")"
    [[ -n "$pessoas" ]] && printf '  %-9s %s\n' "$papel" "$pessoas"
done
admins="$(jq '[.[] | select(.permissions.admin)] | length' <<<"$dados")"
if (( admins > 1 )); then
    echo "⚠ $admins admins. Cada um pode apagar o repositório e mudar as regras — todos precisam?"
fi
echo "Dica: em organizações, prefira dar acesso por TIME (gh api orgs/ORG/teams) a convites individuais."
