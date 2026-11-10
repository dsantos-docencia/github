#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Projeto 01 · Kit de repositório
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Deixa um repositório "pronto para time" em um comando: arquivos de saúde da
#  comunidade, issue form, template de PR, CODEOWNERS, Dependabot e um CI
#  endurecido. Junta os Módulos 03, 04, 05, 07 e 10.
#
#  USO
#    kit.sh [PASTA] [--dono @usuario] [--licenca mit|apache-2.0|gpl-3.0] [--forcar]
#
#  PRINCÍPIOS
#    • Idempotente: rodar de novo não estraga nada — arquivo existente é
#      MANTIDO (a menos que você peça --forcar).
#    • Verificável: no fim, todo YAML gerado é conferido.
#    • A licença vem da API do GitHub (texto oficial), não de uma cópia.
# ============================================================================
set -euo pipefail

pasta='.' dono='' licenca='mit' forcar=0
while (( $# )); do
    case "$1" in
        --dono)    dono="${2:?--dono precisa de um valor}"; shift ;;
        --licenca) licenca="${2:?--licenca precisa de um valor}"; shift ;;
        --forcar)  forcar=1 ;;
        -h|--help) sed -n '/^#  USO/,/^#  PRINCÍPIOS/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)        echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)         pasta="$1" ;;
    esac
    shift
done
[[ -d "$pasta" ]] || { echo "erro: pasta não encontrada: $pasta" >&2; exit 2; }
if [[ -z "$dono" ]]; then
    dono="@$(gh api user --jq .login 2>/dev/null || echo voce)"
fi
[[ "$dono" == @* ]] || dono="@$dono"
nome_dono="${dono#@}"

criados=0 mantidos=0
# escrever CAMINHO  (conteúdo pela entrada padrão)
escrever() {
    local destino="$pasta/$1" conteudo
    conteudo="$(cat)"
    if [[ -e "$destino" && $forcar -eq 0 ]]; then
        printf '  · mantido  %s\n' "$1"; mantidos=$((mantidos + 1)); return 0
    fi
    mkdir -p -- "$(dirname -- "$destino")"
    printf '%s\n' "$conteudo" > "$destino"
    printf '  ✔ criado   %s\n' "$1"; criados=$((criados + 1))
}

echo "➤ Kit de repositório em $pasta (dono: $dono, licença: $licenca)"

escrever README.md <<MD
# $(basename -- "$(cd "$pasta" && pwd)")

> Descreva aqui, em uma frase, o que este projeto faz.

## Como usar
\`\`\`bash
./testes.sh
\`\`\`

## Como contribuir
Leia o [CONTRIBUTING.md](CONTRIBUTING.md).
MD

# LICENSE: texto oficial pela API, com os campos preenchidos.
if [[ ! -e "$pasta/LICENSE" || $forcar -eq 1 ]]; then
    if texto="$(gh api "licenses/$licenca" --jq .body)"; then
        texto="${texto//\[year\]/"$(date +%Y)"}"
        texto="${texto//\[fullname\]/"$nome_dono"}"
        # <<< e não "printf | escrever": num pipe, a função roda num SUBSHELL e
        # o contador "criados" não seria atualizado aqui fora.
        escrever LICENSE <<<"$texto"
    else
        echo "  ✘ licença '$licenca' não encontrada na API — LICENSE não criado" >&2
    fi
else
    escrever LICENSE </dev/null
fi

escrever CONTRIBUTING.md <<'MD'
# Como contribuir

1. Abra (ou escolha) um issue e comente que vai trabalhar nele.
2. Crie uma branch a partir da `main`: `git switch -c tipo/descricao-curta`.
3. Commits no padrão Conventional Commits (`feat:`, `fix:`, `docs:`…).
4. Rode os testes: `./testes.sh`.
5. Abra um pull request preenchendo o template. Uma revisão aprovada e o CI verde são obrigatórios.
MD

escrever CODE_OF_CONDUCT.md <<MD
# Código de conduta

Este projeto adota o [Contributor Covenant 2.1](https://www.contributor-covenant.org/pt-br/version/2/1/code_of_conduct/).
Comportamentos inaceitáveis podem ser relatados em privado a $dono.
MD

escrever SECURITY.md <<'MD'
# Política de segurança

**Não abra issue pública para vulnerabilidades.** Use o botão
**Security → Report a vulnerability** (relato privado) deste repositório.
Respondemos em até 5 dias úteis. Versões suportadas: a mais recente.
MD

escrever .github/ISSUE_TEMPLATE/bug.yml <<'YAML'
name: 🐛 Relatar um bug
description: Algo não funciona como deveria
labels: ["bug"]
body:
  - type: textarea
    id: passos
    attributes:
      label: Passos para reproduzir
    validations:
      required: true
  - type: textarea
    id: esperado
    attributes:
      label: O que você esperava e o que aconteceu
    validations:
      required: true
YAML

escrever .github/ISSUE_TEMPLATE/config.yml <<'YAML'
blank_issues_enabled: false
YAML

escrever .github/pull_request_template.md <<'MD'
## O que muda

## Por quê
<!-- Closes #NUMERO -->

## Como testar

## Checklist
- [ ] Testes passando
- [ ] Revisei o meu próprio diff
- [ ] Documentação atualizada, se necessário
MD

escrever .github/CODEOWNERS <<TXT
# A última regra que casar vence: o padrão geral fica no topo.
*            $dono
/.github/    $dono
TXT

escrever .github/dependabot.yml <<'YAML'
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      acoes:
        patterns: ["*"]
YAML

escrever .github/workflows/ci.yml <<'YAML'
name: CI
on:
  push:
    branches: [main]
  pull_request:
permissions:
  contents: read
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
jobs:
  testes:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - name: Testes
        run: ./testes.sh
YAML

# Conferência final: todo YAML gerado precisa ser válido.
invalidos=0
while IFS= read -r -d '' y; do
    python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' "$y" 2>/dev/null \
        || { echo "  ✘ YAML inválido: ${y#"$pasta"/}" >&2; invalidos=$((invalidos + 1)); }
done < <(find "$pasta/.github" \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)

echo "$criados criados, $mantidos mantidos"
(( invalidos == 0 ))
