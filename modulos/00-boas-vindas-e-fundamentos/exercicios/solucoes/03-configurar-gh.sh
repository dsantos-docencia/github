#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 00.03 — Deixando o gh do seu jeito · SOLUÇÃO COMENTADA
set -euo pipefail

# Chaves de configuração documentadas em: gh help config
gh config set git_protocol ssh
gh config set prompt disabled
# Aspas simples: "@me" chega ao gh sem o shell mexer.
gh alias set minhas 'issue list --assignee @me'
gh alias set rascunho 'pr create --draft --fill'
