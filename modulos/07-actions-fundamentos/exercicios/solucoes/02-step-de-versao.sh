#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 07.02 — Um step que conversa com o runner · SOLUÇÃO COMENTADA
set -euo pipefail

# : "${VAR:?}" falha cedo, com mensagem clara, se o runner não definiu a variável.
: "${GITHUB_OUTPUT:?rode dentro do GitHub Actions (ou defina GITHUB_OUTPUT)}"
: "${GITHUB_STEP_SUMMARY:?rode dentro do GitHub Actions (ou defina GITHUB_STEP_SUMMARY)}"

v="$(cat VERSION 2>/dev/null || true)"
if ! [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
    # "::error file=...::" vira uma anotação vermelha no arquivo, na página do PR.
    echo "::error file=VERSION::versão inválida: $v"
    exit 1
fi
pre=false
[[ "$v" == *-* ]] && pre=true
{
    echo "versao=$v"
    echo "prerelease=$pre"
} >> "$GITHUB_OUTPUT"
echo "### Versão $v" >> "$GITHUB_STEP_SUMMARY"
