#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 06 · Como o servidor recusa um push
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  reproduzir offline o "GH013" do GitHub com um hook pre-receive que bloqueia force push e exclusão da main
#  EXECUTE   bash modulos/06-protecao-e-rulesets/exemplos/03-push-recusado-localmente.sh
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

passo "Servidor bare com uma 'regra' no hook pre-receive"
git init -q --bare servidor.git
cat > servidor.git/hooks/pre-receive <<'HOOK'
#!/usr/bin/env bash
# Recebe pela entrada: <sha-antigo> <sha-novo> <ref> — uma linha por ref enviada.
zero=0000000000000000000000000000000000000000
erro=0
while read -r antigo novo ref; do
    [[ "$ref" == refs/heads/main ]] || continue
    if [[ "$novo" == "$zero" ]]; then
        echo "error: GH013 (simulado): Cannot delete this branch"; erro=1
    elif [[ "$antigo" != "$zero" ]] && ! git merge-base --is-ancestor "$antigo" "$novo"; then
        echo "error: GH013 (simulado): Cannot force-push to this branch"; erro=1
    fi
done
exit "$erro"
HOOK
chmod +x servidor.git/hooks/pre-receive

passo "Clone, dois commits publicados"
git clone -q servidor.git app 2>/dev/null && cd app
printf 'v1\n' > app.txt && git add . && git commit -q -m "feat: v1"
printf 'v2\n' > app.txt && git commit -qam "feat: v2" && git push -q origin main
git log --oneline

passo "Reescrevendo a história e tentando git push --force"
git reset -q --hard HEAD~1
printf 'v2 refeito\n' > app.txt && git commit -qam "feat: v2 (refeito)"
git push --force origin main 2>&1 | sed 's/^/   /' || true

passo "Tentando apagar a main no servidor"
git push origin --delete main 2>&1 | sed 's/^/   /' || true

echo
echo "O GitHub faz o mesmo (com muito mais regras) — só que configurado por rulesets, sem hooks."
