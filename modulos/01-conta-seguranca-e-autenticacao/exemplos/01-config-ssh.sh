#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 01 · Configuração SSH para o GitHub
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  montar um ~/.ssh/config didático (numa pasta temporária) e ver a configuração efetiva com ssh -G
#  EXECUTE   bash modulos/01-conta-seguranca-e-autenticacao/exemplos/01-config-ssh.sh
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

# --- gh simulado (offline): cada chamada é registrada, nada vai à internet ---
# shellcheck source=/dev/null
source "$CURSO/ferramentas/lib/gh-simulado.sh"
export LAB_REPO='aluno/laboratorio'
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

# Tudo acontece em $LAB/.ssh — o seu ~/.ssh nunca é tocado.
mkdir -p .ssh && chmod 700 .ssh

passo "1. Gerar o par de chaves (se o ssh-keygen existir)"
if command -v ssh-keygen >/dev/null; then
    mostra ssh-keygen -q -t ed25519 -N '' -C 'ana@exemplo.dev' -f .ssh/id_ed25519_github
    echo "chave PÚBLICA (esta vai para o GitHub):"
    cat .ssh/id_ed25519_github.pub
    mostra ssh-keygen -lf .ssh/id_ed25519_github.pub     # impressão digital
else
    echo "(ssh-keygen não instalado aqui — no seu computador o comando é o de cima)"
fi

passo "2. Escrever o config"
cat > .ssh/config <<CFG
Host github.com
    HostName github.com
    User git
    IdentityFile $LAB/.ssh/id_ed25519_github
    IdentitiesOnly yes
    AddKeysToAgent yes

Host github-443
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile $LAB/.ssh/id_ed25519_github
CFG
chmod 600 .ssh/config
cat .ssh/config

passo "3. O que o ssh realmente usaria (ssh -G resolve o config sem conectar)"
if command -v ssh >/dev/null; then
    ssh -G -F .ssh/config github-443 | grep -E '^(hostname|port|user|identitiesonly) '
else
    echo "(cliente ssh não instalado aqui)"
fi

passo "4. URLs equivalentes de um remoto"
echo "HTTPS ......... https://github.com/aluno/laboratorio.git"
echo "SSH ........... git@github.com:aluno/laboratorio.git"
echo "SSH porta 443 . git@github-443:aluno/laboratorio.git"
