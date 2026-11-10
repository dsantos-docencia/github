#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 08.02 — Uma ação composta com entrada e saída · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github/actions/saudacao
cat > .github/actions/saudacao/action.yml <<'YAML'
name: Saudação
description: Gera uma mensagem de boas-vindas
inputs:
  nome:
    description: Quem saudar
    required: true
outputs:
  mensagem:
    description: A mensagem gerada
    value: ${{ steps.gerar.outputs.mensagem }}
runs:
  using: composite
  steps:
    - id: gerar
      shell: bash                  # obrigatório em ação composta
      env:
        NOME: ${{ inputs.nome }}   # o input entra como DADO (variável), nunca colado no script
      run: echo "mensagem=Olá, $NOME" >> "$GITHUB_OUTPUT"
YAML
