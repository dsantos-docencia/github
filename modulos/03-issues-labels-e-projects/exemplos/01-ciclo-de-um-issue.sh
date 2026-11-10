#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 03 · O ciclo de vida de um issue
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  criar, rotular, comentar e fechar um issue pelo gh — no simulado ou no seu repositório de laboratório
#  EXECUTE   bash modulos/03-issues-labels-e-projects/exemplos/01-ciclo-de-um-issue.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/03-issues-labels-e-projects/exemplos/01-ciclo-de-um-issue.sh   (GitHub de verdade)
# ============================================================================
set -euo pipefail
CURSO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"

# --- Laboratório descartável --------------------------------------------------
# Pasta temporária apagada ao final; Git isolado (não lê nem altera o seu
# ~/.gitconfig); identidade fixa para os commits de demonstração.
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT; cd "$LAB"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$LAB/.gitconfig-lab" GIT_PAGER=cat
export GIT_AUTHOR_NAME='Ana Dev' GIT_AUTHOR_EMAIL='ana@exemplo.dev'
export GIT_COMMITTER_NAME='Ana Dev' GIT_COMMITTER_EMAIL='ana@exemplo.dev'
git config --global init.defaultBranch main
git config --global advice.detachedHead false

# --- gh: simulado por padrão; o de verdade com GH_REAL=1 ---------------------
# Simulado = offline, sem conta, nada é criado; cada chamada fica registrada.
if [[ "${GH_REAL:-0}" == 1 ]]; then
    : "${LAB_REPO:?defina LAB_REPO=seu-usuario/lab-github (veja laboratorio/)}"
    gh auth status >/dev/null 2>&1 || { echo "rode 'gh auth login' antes" >&2; exit 1; }
else
    # shellcheck source=/dev/null
    source "$CURSO/ferramentas/lib/gh-simulado.sh"
    LAB_REPO='aluno/laboratorio'
fi
passo()  { printf '\n== %s ==\n' "$*"; }
# mostra: exibe o comando (com aspas só onde precisa) e depois o executa
mostra() {
    local a linha='$'
    for a in "$@"; do
        if [[ "$a" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
            if [[ "$a" == *"'"* || "$a" == *$'\n'* ]]; then printf -v a '%q' "$a"; else a="'$a'"; fi
        fi
        linha+=" $a"
    done
    printf '%s\n' "$linha"; "$@"
}

passo "Relato escrito num arquivo (corpos longos ficam melhores fora da linha de comando)"
cat > relato.md <<'MD'
**Passos:** 1. Entrar  2. Perfil → Foto  3. Enviar foto de 6 MB  4. Salvar
**Esperado:** aviso "máximo 5 MB"   **Obtido:** erro 500
**Ambiente:** Chrome 140 · v1.1.0
MD

passo "Garantir que os labels existem (--force = cria ou atualiza)"
mostra gh label create bug --color d73a4a --description "Algo não funciona" --force -R "$LAB_REPO"
mostra gh label create "prioridade:alta" --color d93f0b --description "Resolver nesta semana" --force -R "$LAB_REPO"

passo "Criar o issue"
url="$(gh issue create -R "$LAB_REPO" --title "Erro 500 ao salvar perfil com foto grande" \
        --body-file relato.md --label bug --label "prioridade:alta")"
echo "criado: $url"
numero="${url##*/}"      # o número é o último pedaço da URL

passo "Comentar e fechar"
mostra gh issue comment "$numero" -R "$LAB_REPO" --body "Reproduzido. Causa: limite do proxy."
mostra gh issue close "$numero" -R "$LAB_REPO" --reason completed --comment "Corrigido na v1.1.1."
