#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 04.02 — Template de pull request · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .github
cat > .github/pull_request_template.md <<'MD'
## O que muda
<!-- Uma ou duas frases. -->

## Por quê
<!-- O problema ou a necessidade. Ligue o issue: Closes #NUMERO -->

## Como testar
<!-- Passos para quem revisa conferir. -->

## Checklist
- [ ] Rodei os testes localmente
- [ ] Revisei o meu próprio diff
- [ ] Atualizei a documentação, se necessário
MD
