#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · laboratorio/verificar-ambiente.sh
#  Confere se a sua máquina tem o necessário para o curso (e o que é opcional).
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
set -uo pipefail

faltam=0
item() {   # item OBRIGATÓRIO(1/0) COMANDO DESCRIÇÃO [comando de versão]
    local obrig="$1" cmd="$2" desc="$3" versao="${4:-}"
    if command -v "$cmd" >/dev/null 2>&1; then
        printf '  ✔ %-11s %s %s\n' "$cmd" "$desc" "${versao:+($(eval "$versao" 2>/dev/null | head -1))}"
    elif (( obrig )); then
        printf '  ✘ %-11s %s — OBRIGATÓRIO\n' "$cmd" "$desc"; faltam=$((faltam + 1))
    else
        printf '  · %-11s %s — opcional\n' "$cmd" "$desc"
    fi
}
echo "Obrigatórios (exemplos simulados e corretor):"
item 1 bash    "shell"                 'bash --version'
item 1 git     "Git"                   'git --version'
item 1 jq      "filtros JSON"          'jq --version'
item 1 python3 "conversor YAML→JSON"   'python3 --version'
if python3 -c 'import yaml' 2>/dev/null; then echo "  ✔ PyYAML     módulo yaml do Python"
else echo "  ✘ PyYAML     módulo yaml do Python — OBRIGATÓRIO (pip install pyyaml / apt install python3-yaml)"; faltam=$((faltam + 1)); fi
echo "Para o GitHub de verdade e ferramentas extras:"
item 0 gh         "GitHub CLI"                    'gh --version'
item 0 shellcheck "lint de scripts"               'shellcheck --version | sed -n 2p'
item 0 actionlint "lint de workflows"             'actionlint --version'
item 0 zizmor     "segurança de workflows"        'zizmor --version'
item 0 act        "rodar workflows localmente"    'act --version'
item 0 docker     "containers (act, laboratório)" 'docker --version'
if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then echo "  ✔ gh logado como $(gh api user --jq .login 2>/dev/null)"
    else echo "  · gh instalado, mas sem login (gh auth login) — só necessário para GH_REAL=1"; fi
fi
echo
if (( faltam )); then echo "Faltam $faltam item(ns) obrigatório(s)."; exit 1; fi
echo "Tudo pronto para o curso. 🚀"
