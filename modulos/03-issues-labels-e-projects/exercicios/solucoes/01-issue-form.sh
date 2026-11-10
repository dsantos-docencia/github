#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 03.01 — Um formulário de bug que não aceita relato pela metade · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github/ISSUE_TEMPLATE
cat > .github/ISSUE_TEMPLATE/bug.yml <<'YAML'
name: Relatar um bug
description: Algo não funciona como deveria — conte como reproduzir.
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: Obrigado por relatar! Quanto mais preciso, mais rápido resolvemos.
  - type: textarea
    id: passos
    attributes:
      label: Passos para reproduzir
      placeholder: |
        1. ...
        2. ...
    validations:
      required: true
  - type: dropdown
    id: gravidade
    attributes:
      label: Gravidade
      options:
        - Baixa
        - Média
        - Alta
  - type: textarea
    id: logs
    attributes:
      label: Logs (sem senhas!)
      render: shell
YAML
# Sem issue "em branco": todo relato passa por um formulário.
cat > .github/ISSUE_TEMPLATE/config.yml <<'YAML'
blank_issues_enabled: false
YAML
