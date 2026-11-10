#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · laboratorio/criar-lab.sh
#  Cria o SEU repositório de laboratório no GitHub, já povoado com labels,
#  issues, CODEOWNERS e um workflow de CI — o cenário dos exemplos GH_REAL=1.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#
#  USO
#    ./laboratorio/criar-lab.sh                 # cria seu-usuario/lab-github (público)
#    ./laboratorio/criar-lab.sh --nome meu-lab  # outro nome
#    ./laboratorio/criar-lab.sh --privado       # privado (veja a observação abaixo)
#    ./laboratorio/criar-lab.sh --simular       # mostra o que faria, sem internet
#
#  POR QUE PÚBLICO POR PADRÃO?
#    O conteúdo é fictício, e repositórios públicos têm Actions ilimitado,
#    rulesets e secret scanning gratuitos — exatamente o que os Módulos 06–10
#    praticam. Num privado do plano Free, rulesets e parte da segurança não
#    estão disponíveis.
# ============================================================================
set -euo pipefail

AQUI="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
nome='lab-github' visibilidade='--public' simular=0
while (( $# )); do
    case "$1" in
        --nome)    nome="${2:?--nome precisa de um valor}"; shift ;;
        --privado) visibilidade='--private' ;;
        --simular) simular=1 ;;
        -h|--help) sed -n '/^#  USO/,/^#  POR QUE/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        *) echo "opção desconhecida: $1 (use --help)" >&2; exit 2 ;;
    esac
    shift
done

if (( simular )); then
    # shellcheck source=../ferramentas/lib/gh-simulado.sh
    source "$AQUI/../ferramentas/lib/gh-simulado.sh"
fi
command -v gh >/dev/null || { echo "instale o GitHub CLI: https://cli.github.com" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "faça login antes: gh auth login" >&2; exit 1; }

dono="$(gh api user --jq .login)"
repo="$dono/$nome"
echo "➤ Criando o laboratório $repo"

# 1. Conteúdo inicial num diretório temporário -------------------------------
tmp="$(mktemp -d)"; trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/.github/workflows"
cat > "$tmp/README.md" <<MD
# 🧪 Laboratório do Curso de GitHub

Repositório de prática de **@$dono** para o [Curso de GitHub](https://github.com/dsantos-docencia/github)
do Prof. Daniel Santos. Conteúdo fictício — pode quebrar à vontade.
MD
printf '*  @%s\n' "$dono" > "$tmp/.github/CODEOWNERS"
cat > "$tmp/testes.sh" <<'SH'
#!/usr/bin/env bash
# Teste de mentira para o CI ter o que rodar.
set -euo pipefail
echo "✔ todos os testes passaram"
SH
chmod +x "$tmp/testes.sh"
cat > "$tmp/.github/workflows/ci.yml" <<'YML'
name: CI
on:
  push:
    branches: [main]
  pull_request:
permissions:
  contents: read
jobs:
  verificar:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - run: ./testes.sh
YML
git -C "$tmp" init -q -b main
git -C "$tmp" add .
git -C "$tmp" -c user.name="$dono" -c user.email="$dono@users.noreply.github.com" \
    commit -q -m "chore: laboratório do Curso de GitHub"

# 2. Publicar ------------------------------------------------------------------
gh repo create "$repo" "$visibilidade" --source "$tmp" --remote origin --push \
    --description "Laboratório do Curso de GitHub (Prof. Daniel Santos)"

# 3. Labels e issues de exemplo (os mesmos dados do simulador) ------------------
while IFS='|' read -r label cor descricao; do
    gh label create "$label" --color "$cor" --description "$descricao" --force -R "$repo"
done <<'TSV'
bug|d73a4a|Algo não funciona
melhoria|a2eeef|Nova funcionalidade ou pedido
documentação|0075ca|Melhorias na documentação
good first issue|7057ff|Bom para quem está começando
prioridade:alta|d93f0b|Resolver nesta semana
TSV
while IFS='|' read -r titulo labels; do
    args=()
    IFS=',' read -ra lista <<<"$labels"
    for l in "${lista[@]}"; do args+=(--label "$l"); done
    gh issue create -R "$repo" --title "$titulo" --body "Issue de exemplo do laboratório." "${args[@]}" >/dev/null
done <<'TSV'
Erro 500 ao salvar o perfil|bug,prioridade:alta
Adicionar modo escuro|melhoria
Botão de login desalinhado no celular|bug
Documentar a API de pedidos|documentação,good first issue
TSV

cat <<FIM

✅ Laboratório pronto: https://github.com/$repo

Para rodar os exemplos no GitHub de verdade:
    export GH_REAL=1 LAB_REPO=$repo
    bash modulos/03-issues-labels-e-projects/exemplos/02-busca-avancada.sh

Para apagar quando terminar o curso:  ./laboratorio/destruir-lab.sh --nome $nome
FIM
if (( simular )); then
    echo; echo "── modo --simular: nada foi criado. Chamadas que seriam feitas:"
    chamadas_gh
fi
