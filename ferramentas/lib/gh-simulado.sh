# shellcheck shell=bash
# ============================================================================
#  Curso de GitHub — Colaboração, Automação e Segurança
#  ferramentas/lib/gh-simulado.sh — liga o gh simulado e oferece asserções
#
#  Autor: Prof. Daniel Santos · https://github.com/dsantos-docencia/github
#  © 2026 Daniel Santos — Código sob PolyForm Noncommercial 1.0.0 (veja LICENSE)
# ============================================================================
#
#  Ao ser carregado (source), este arquivo:
#    • coloca ferramentas/simulador/ na FRENTE do PATH → "gh" passa a ser o
#      simulador (o gh real continua instalado, só fica escondido);
#    • aponta GH_CONFIG_DIR para uma pasta temporária → nada do seu login real
#      é lido nem alterado;
#    • zera GH_TOKEN/GITHUB_TOKEN → nenhum token real vaza para um exemplo.
#
#  Funções para testes e exemplos:
#    chamadas_gh                    mostra o registro de chamadas
#    afirmar_chamou_gh PADRÃO [msg] alguma chamada casa com o glob PADRÃO
#    afirmar_nao_chamou_gh PADRÃO   nenhuma chamada casa com PADRÃO
#    contar_chamadas_gh PADRÃO      quantas chamadas casam
#    valor_opcao_gh PADRÃO OPÇÃO    valor de OPÇÃO (--title, -f…) na última
#                                   chamada que casa com PADRÃO
#    entrada_gh PADRÃO              corpo enviado por stdin (--input -)
#    simular_gh PADRÃO CONTEÚDO [CÓDIGO]  injeta uma resposta (vale antes do mapa padrão)
#    usar_gh_real                   tira o simulador do PATH (o teste usa o gh instalado)
#
#  Os padrões são globs comparados com a chamada em formato LEGÍVEL (o mesmo
#  que chamadas_gh mostra, sem o "gh " inicial), por exemplo:
#    'issue create*'   "label create 'good first issue' *"   'pr merge*--squash*'
# ============================================================================

GH_SIMULADOR_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../simulador" && pwd)"
case ":$PATH:" in *":$GH_SIMULADOR_DIR:"*) ;; *) PATH="$GH_SIMULADOR_DIR:$PATH" ;; esac
export PATH GH_SIMULADOR_DIR

# gh_simulado_reiniciar — registro, mapa e configuração novos (o corretor
# chama isto antes de CADA caso de teste, para um não enxergar o outro).
gh_simulado_reiniciar() {
    local aux
    aux="$(mktemp -d)"
    export GH_SIMULADO_LOG="$aux/chamadas.log" GH_SIMULADO_MAPA="$aux/mapa.tsv"
    export GH_CONFIG_DIR="$aux/config-gh"
    mkdir -p -- "$GH_CONFIG_DIR"; : > "$GH_SIMULADO_LOG"
}
# Se já existe um registro (ex.: o corretor chamou um script que também carrega
# esta lib), reaproveitamos — senão as chamadas iriam para um registro órfão.
[[ -n "${GH_SIMULADO_LOG:-}" && -f "${GH_SIMULADO_LOG}" ]] || gh_simulado_reiniciar
export GH_PROMPT_DISABLED=1 GH_NO_UPDATE_NOTIFIER=1 GH_SPINNER_DISABLED=1 NO_COLOR=1
unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN

# Só as linhas de chamada (os blocos de stdin ficam entre marcadores).
_linhas_gh() {
    awk '/^--- entrada padrão ---$/{d=1;next} /^--- fim ---$/{d=0;next} !d && /^gh /{print substr($0,4)}' \
        "$GH_SIMULADO_LOG" 2>/dev/null
}

# _linhas_legiveis — cada chamada como você a digitaria: aspas simples só
# onde precisa ('good first issue'). É neste formato que os PADRÕES casam.
_linhas_legiveis() {
    local l a saida
    local -a args
    while IFS= read -r l; do
        eval "args=($l)"
        saida='gh'
        for a in "${args[@]}"; do
            if [[ "$a" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
                if [[ "$a" == *"'"* || "$a" == *$'\n'* ]]; then printf -v a '%q' "$a"; else a="'$a'"; fi
            fi
            saida+=" $a"
        done
        printf '%s\n' "${saida#gh }"
    done < <(_linhas_gh)
}

chamadas_gh() { _linhas_legiveis | sed 's/^/gh /'; }

contar_chamadas_gh() {
    local n=0 l
    while IFS= read -r l; do
        # shellcheck disable=SC2053
        [[ "$l" == $1 ]] && n=$((n + 1))
    done < <(_linhas_legiveis)
    printf '%s\n' "$n"
}

afirmar_chamou_gh() {
    (( $(contar_chamadas_gh "$1") > 0 )) && return 0
    _falhar "${2:-o script não chamou: gh $1}" "chamadas registradas:" "$(chamadas_gh | sed 's/^/  /')"
}

afirmar_nao_chamou_gh() {
    (( $(contar_chamadas_gh "$1") == 0 )) && return 0
    _falhar "${2:-o script NÃO deveria chamar: gh $1}" "$(chamadas_gh | sed 's/^/  /')"
}

# valor_opcao_gh PADRÃO OPÇÃO — aceita "--title X" e "--title=X".
valor_opcao_gh() {
    local l bruta ultima='' i
    # Lê as duas versões lado a lado: casa o padrão na legível, usa a bruta.
    while IFS= read -r l && IFS= read -r bruta <&3; do
        # shellcheck disable=SC2053
        [[ "$l" == $1 ]] && ultima="$bruta"
    done < <(_linhas_legiveis) 3< <(_linhas_gh)
    [[ -n "$ultima" ]] || return 1
    local -a a
    # A linha foi gravada com printf %q: eval a reconstrói com segurança.
    eval "a=($ultima)"
    for ((i = 0; i < ${#a[@]}; i++)); do
        if [[ "${a[i]}" == "$2" ]]; then printf '%s\n' "${a[i+1]:-}"; return 0; fi
        if [[ "${a[i]}" == "$2="* ]]; then printf '%s\n' "${a[i]#"$2="}"; return 0; fi
    done
    return 1
}

# entrada_gh PADRÃO — corpo de stdin da última chamada que casa com PADRÃO.
entrada_gh() {
    local l linha='' dentro=0 buf='' achou=''
    while IFS= read -r l; do
        if [[ "$l" == '--- entrada padrão ---' ]]; then dentro=1; buf=''; continue; fi
        if [[ "$l" == '--- fim ---' ]]; then
            dentro=0
            # shellcheck disable=SC2053
            [[ "$linha" == $1 ]] && achou="$buf"
            continue
        fi
        if (( dentro )); then buf+="$l"$'\n'; continue; fi
        if [[ "$l" == 'gh '* ]]; then
            local -a a2; eval "a2=(${l#gh })"
            linha=''; local x
            for x in "${a2[@]}"; do
                if [[ "$x" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
                    if [[ "$x" == *"'"* || "$x" == *$'\n'* ]]; then printf -v x '%q' "$x"; else x="'$x'"; fi
                fi
                linha+="${linha:+ }$x"
            done
        fi
    done < "$GH_SIMULADO_LOG"
    printf '%s' "$achou"
}

simular_gh() {   # simular_gh PADRÃO CONTEÚDO [CÓDIGO]
    local arq
    arq="$(mktemp "$(dirname -- "$GH_SIMULADO_MAPA")/resposta.XXXXXX")"
    printf '%s\n' "$2" > "$arq"
    # O mapa do teste é consultado antes do padrão; prepend = o mais novo vence.
    { printf '%s\t%s\t%s\n' "$1" "$arq" "${3:-0}"; cat -- "$GH_SIMULADO_MAPA" 2>/dev/null || true; } > "$arq.mapa"
    mv -- "$arq.mapa" "$GH_SIMULADO_MAPA"
}

usar_gh_real() {
    PATH="${PATH//"$GH_SIMULADOR_DIR:"/}"
    export PATH
    command -v gh >/dev/null || _falhar "este teste usa o gh REAL e ele não está instalado (veja laboratorio/)"
}

# Fallback de _falhar para quando a lib é usada fora do framework de testes.
declare -F _falhar >/dev/null || _falhar() { printf '✘ %s\n' "$@" >&2; return 1; }
