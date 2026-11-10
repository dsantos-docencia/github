#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 00 · Markdown no padrão do GitHub
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  gerar um README com os recursos do GFM: alerta, tarefas, tabela, mermaid e referências
#  EXECUTE   bash modulos/00-boas-vindas-e-fundamentos/exemplos/02-markdown-gfm.sh
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

passo "Gerando README.md com os recursos do GitHub Flavored Markdown"
cat > README.md <<'MD'
# 🛒 Loja do Bairro

> [!IMPORTANT]
> Projeto didático do Curso de GitHub — não use em produção.

## Roteiro
- [x] cadastro de produtos
- [ ] carrinho (#12)
- [ ] pagamento por Pix

## Comandos
| Ação | Comando |
|---|---|
| testar | `./testes.sh` |
| publicar | `gh release create` |

## Fluxo
```mermaid
graph LR
  Issue --> Branch --> PR --> Merge
```

Dúvidas? Fale com @aluno ou veja a discussão em aluno/laboratorio#3.[^1]

[^1]: As referências viram links automáticos no GitHub.
MD
cat README.md

passo "Conferindo os recursos com grep (é assim que o corretor olha seu README)"
grep -c '^- \[[ x]\]' README.md | xargs printf 'itens de tarefa: %s\n'
grep -q '^> \[!IMPORTANT\]' README.md && echo "alerta: sim"
grep -q '^```mermaid' README.md && echo "diagrama mermaid: sim"

passo "Pré-visualizar de verdade"
echo "Envie para um repositório e abra no navegador, ou use a extensão: gh extension install yusukebe/gh-markdown-preview"
