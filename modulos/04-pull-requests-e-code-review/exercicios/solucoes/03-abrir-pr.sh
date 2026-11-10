#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 04.03 — Abrir um PR completo pelo terminal · SOLUÇÃO COMENTADA
set -euo pipefail

issue="${1:-}"
[[ "$issue" =~ ^[0-9]+$ ]] || { echo "uso: $0 <número-do-issue>" >&2; exit 2; }
cd app
branch="$(git branch --show-current)"          # nunca fixo: o script serve para qualquer branch
titulo="$(git log -1 --format=%s)"             # %s = assunto (1ª linha) da mensagem
git push -q -u origin "$branch"
# $'...' interpreta \n: o corpo fica com duas linhas.
gh pr create --base main --head "$branch" --title "$titulo" \
    --body $'Gerado pelo script de PR.\n\nCloses #'"$issue" --draft
