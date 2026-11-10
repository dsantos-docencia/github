#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 08 · Quantos jobs essa matriz gera?
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  calcular a expansão de uma matriz com exclude e include, como o GitHub faz
#  EXECUTE   bash modulos/08-actions-avancado/exemplos/01-expandindo-a-matriz.sh
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

cat > matriz.yml <<'YAML'
os: [ubuntu-latest, windows-latest]
node: [20, 22, 24]
exclude:
  - {os: windows-latest, node: 20}
include:
  - {os: ubuntu-latest, node: 24, experimental: true}   # casa com uma combinação: só acrescenta a chave
  - {os: macos-latest, node: 24}                        # não casa com nenhuma: vira job NOVO
YAML

passo "A matriz"
cat matriz.yml

passo "Expansão (produto cartesiano → exclude → include), em Python"
python3 - matriz.yml <<'PY'
import itertools, sys, yaml
m = yaml.safe_load(open(sys.argv[1]))
exc, inc = m.pop("exclude", []), m.pop("include", [])
chaves = list(m)
combos = [dict(zip(chaves, v)) for v in itertools.product(*m.values())]
print(f"1) produto: {len(combos)} combinações")
combos = [c for c in combos if not any(all(c.get(k) == v for k, v in e.items()) for e in exc)]
print(f"2) depois do exclude: {len(combos)}")
for i in inc:
    base = {k: v for k, v in i.items() if k in chaves}
    alvo = [c for c in combos if all(c[k] == v for k, v in base.items())]
    if alvo:
        for c in alvo: c.update(i)
    else:
        combos.append(dict(i))
print(f"3) depois do include: {len(combos)} jobs\n")
for c in combos: print("   ", c)
PY
