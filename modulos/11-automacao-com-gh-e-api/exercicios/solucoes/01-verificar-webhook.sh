#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.01 — Verificador de assinatura de webhook · SOLUÇÃO COMENTADA
set -euo pipefail

segredo="${1:-}" corpo="${2:-}" recebida="${3:-}"
if [[ -z "$segredo" || -z "$corpo" || -z "$recebida" || ! -f "$corpo" ]]; then
    echo "uso: $0 <segredo> <arquivo-do-corpo> <sha256=assinatura>" >&2
    exit 2
fi
[[ "$recebida" == sha256=* ]] || { echo "formato inválido" >&2; exit 1; }

# < arquivo: o openssl lê os bytes exatos (sem \n extra). A saída é
# "SHA2-256(stdin)= <hex>" ou "(stdin)= <hex>": ficamos com a última palavra.
calculada="sha256=$(openssl dgst -sha256 -hmac "$segredo" < "$corpo" | awk '{print $NF}')"

# Num servidor, compare em TEMPO CONSTANTE (hmac.compare_digest). Aqui, para
# um script local, a comparação simples basta.
if [[ "$calculada" == "$recebida" ]]; then
    echo "válida"
else
    echo "inválida" >&2
    exit 1
fi
