#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 03.02 — Labels padronizados em lote · SOLUÇÃO COMENTADA
set -euo pipefail

arquivo="${1:?uso: $0 <labels.tsv> <dono/repo>}"
repo="${2:?uso: $0 <labels.tsv> <dono/repo>}"
[[ -f "$arquivo" ]] || { echo "erro: arquivo não encontrado: $arquivo" >&2; exit 1; }

n=0
# IFS=$'\t' separa só por TAB (a descrição pode ter espaços).
# "|| [[ -n $nome ]]" processa a última linha mesmo sem \n no final.
while IFS=$'\t' read -r nome cor descricao || [[ -n "$nome" ]]; do
    [[ -z "$nome" || "$nome" == \#* ]] && continue
    gh label create "$nome" --color "$cor" --description "$descricao" --force -R "$repo"
    n=$((n + 1))
done < "$arquivo"
echo "$n labels sincronizados"
