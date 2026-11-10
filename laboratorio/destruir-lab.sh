#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · laboratorio/destruir-lab.sh
#  Apaga o repositório de laboratório — com confirmação, porque é irreversível.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   ./laboratorio/destruir-lab.sh [--nome lab-github]
#  Apagar exige o escopo delete_repo, que o login padrão NÃO pede (de propósito):
#        gh auth refresh -s delete_repo
# ============================================================================
set -euo pipefail

nome='lab-github'
[[ "${1:-}" == "--nome" ]] && nome="${2:?--nome precisa de um valor}"

dono="$(gh api user --jq .login)"
repo="$dono/$nome"
gh repo view "$repo" >/dev/null 2>&1 || { echo "não encontrei $repo — nada a fazer."; exit 0; }

echo "⚠ Isto APAGA $repo: código, issues, PRs, Actions. Não há lixeira garantida."
echo "  (Prefere guardar? Arquive em vez de apagar: gh repo archive $repo)"
read -r -p "Digite o nome completo ($repo) para confirmar: " resposta
[[ "$resposta" == "$repo" ]] || { echo "Confirmação não confere. Nada foi apagado."; exit 1; }

gh repo delete "$repo" --yes
echo "🗑 $repo apagado."
