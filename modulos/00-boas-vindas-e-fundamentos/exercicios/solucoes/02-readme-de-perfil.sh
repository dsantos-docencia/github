#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 00.02 — O repositório especial de perfil · SOLUÇÃO COMENTADA
set -euo pipefail

usuario="${1:-}"
if [[ -z "$usuario" ]]; then
    echo "uso: $0 <seu-usuario-do-github>" >&2
    exit 2
fi
git init -q -b main "$usuario"
# printf em vez de echo: comportamento previsível com qualquer texto
printf '### Olá, eu sou @%s 👋\n\n- 🎓 Aprendendo GitHub no curso do Prof. Daniel Santos\n' "$usuario" > "$usuario/README.md"
git -C "$usuario" add README.md
git -C "$usuario" commit -q -m "docs: README do perfil"
