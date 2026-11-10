#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 05.03 — Licença oficial via API · SOLUÇÃO COMENTADA
set -euo pipefail

chave="${1:-}" ano="${2:-}" nome="${3:-}"
if [[ -z "$chave" || -z "$ano" || -z "$nome" ]]; then
    echo "uso: $0 <chave> <ano> <nome>   ex.: $0 mit 2026 'Ana Dev'" >&2
    exit 2
fi
# Se o gh falhar, o "if !" captura — e não chegamos a criar o arquivo.
if ! texto="$(gh api "licenses/$chave" --jq .body)"; then
    echo "erro: licença '$chave' não encontrada" >&2
    exit 1
fi
# Substituição do Bash: sem regex, sem surpresa com / no nome.
# As aspas EM VOLTA da substituta ("$nome") importam: no Bash 5.2+, um & sem
# aspas na substituta é trocado pelo trecho encontrado (opção patsub_replacement).
texto="${texto//\[year\]/"$ano"}"
texto="${texto//\[fullname\]/"$nome"}"
printf '%s\n' "$texto" > LICENSE
