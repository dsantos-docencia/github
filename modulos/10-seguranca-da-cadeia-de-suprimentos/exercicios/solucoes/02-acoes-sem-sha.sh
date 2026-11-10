#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 10.02 — Detector de ações não fixadas · SOLUÇÃO COMENTADA
set -euo pipefail

pasta="${1:-.github/workflows}"
[[ -d "$pasta" ]] || { echo "erro: pasta não encontrada: $pasta" >&2; exit 2; }

achou=0
shopt -s nullglob
for arq in "$pasta"/*.yml "$pasta"/*.yaml; do
    # grep -n: "NÚMERO:conteúdo" de cada linha com uses:
    while IFS=: read -r linha conteudo; do
        ref="${conteudo#*uses:}"             # tudo depois de "uses:"
        ref="${ref%%#*}"                     # tira comentário
        ref="${ref//[\"\' ]/}"               # tira aspas e espaços
        [[ -z "$ref" || "$ref" == ./* || "$ref" == docker://* ]] && continue
        if [[ "$ref" != *@* || ! "${ref##*@}" =~ ^[0-9a-f]{40}$ ]]; then
            echo "$arq:$linha: $ref"
            achou=1
        fi
    done < <(grep -nE '^[[:space:]]*(-[[:space:]]*)?uses:' "$arq")
done
exit "$achou"
