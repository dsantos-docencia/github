#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 06.02 — Aplicar um ruleset sem duplicar · SOLUÇÃO COMENTADA
set -euo pipefail

repo="${1:?uso: $0 <dono/repo> <ruleset.json>}"
arquivo="${2:?uso: $0 <dono/repo> <ruleset.json>}"
[[ -f "$arquivo" ]] || { echo "erro: arquivo não encontrado: $arquivo" >&2; exit 1; }
jq -e . "$arquivo" >/dev/null 2>&1 || { echo "erro: JSON inválido em $arquivo" >&2; exit 1; }

nome="$(jq -r .name "$arquivo")"
# --arg passa o nome como DADO, não como pedaço do filtro: um nome com aspas
# não quebra (nem injeta código) no programa jq.
id="$(gh api "repos/$repo/rulesets" | jq -r --arg n "$nome" '.[] | select(.name == $n) | .id' | head -1)"

if [[ -n "$id" ]]; then
    gh api -X PUT "repos/$repo/rulesets/$id" --input "$arquivo" >/dev/null
    echo "atualizado: $nome ($id)"
else
    gh api -X POST "repos/$repo/rulesets" --input "$arquivo" >/dev/null
    echo "criado: $nome"
fi
