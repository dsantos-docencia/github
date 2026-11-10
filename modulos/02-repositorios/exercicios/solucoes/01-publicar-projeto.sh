#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 02.01 — Publicar um projeto novo · SOLUÇÃO COMENTADA
set -euo pipefail

git init -q -b main site
printf '# Site da Loja do Bairro\n' > site/README.md
printf 'node_modules/\n.env\n' > site/.gitignore
git -C site add README.md .gitignore
git -C site commit -q -m "chore: estrutura inicial"
# --source aponta a pasta; --remote nomeia o remoto que o gh vai criar.
gh repo create site --private --source site --remote origin \
    --description "Site da Loja do Bairro"
