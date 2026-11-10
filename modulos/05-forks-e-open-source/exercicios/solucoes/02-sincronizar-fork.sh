#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 05.02 — Sincronizar o fork com o original · SOLUÇÃO COMENTADA
set -euo pipefail

url="${1:?uso: $0 <url-do-upstream>}"
cd meu-fork
# get-url falha se o remoto não existe — e aí o criamos. Idempotente.
git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$url"
git fetch -q upstream
git switch -q main
# --ff-only: se a main do fork divergiu, o merge falha e o set -e encerra o script.
git merge -q --ff-only upstream/main
git push -q origin main
echo "fork sincronizado em $(git rev-parse --short HEAD)"
