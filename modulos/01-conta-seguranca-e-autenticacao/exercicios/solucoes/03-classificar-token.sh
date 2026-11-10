#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 01.03 — Classificador de tokens · SOLUÇÃO COMENTADA
set -euo pipefail

token="${1:-}"
[[ -n "$token" ]] || { echo "uso: $0 <token>" >&2; exit 2; }
# case com padrões glob: a ordem não importa aqui porque os prefixos não se sobrepõem.
case "$token" in
    ghp_*)        tipo='pessoal clássico' ;;
    github_pat_*) tipo='pessoal fine-grained' ;;
    gho_*)        tipo='oauth' ;;
    ghu_*)        tipo='app usuário-servidor' ;;
    ghs_*)        tipo='app servidor-servidor' ;;
    ghr_*)        tipo='app refresh' ;;
    *)            echo "desconhecido" >&2; exit 1 ;;
esac
# ${var:0:8} = os 8 primeiros caracteres: suficiente para identificar, inútil para usar.
printf '%s · %s…\n' "$tipo" "${token:0:8}"
