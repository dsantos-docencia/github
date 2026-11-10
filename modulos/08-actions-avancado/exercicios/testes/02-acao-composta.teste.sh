# shellcheck shell=bash
# Testes do exercício 08.02 — Uma ação composta com entrada e saída
A=.github/actions/saudacao/action.yml
teste_estrutura() {
    executar; afirmar_arquivo "$A"
    afirmar_jq "$A" '(.name|length)>0 and (.description|length)>0' "name e description"
    afirmar_jq "$A" '.inputs.nome.required == true'
    afirmar_jq "$A" '.outputs.mensagem.value == "${{ steps.gerar.outputs.mensagem }}"'
    afirmar_jq "$A" '.runs.using == "composite"'
}
teste_step_gerar() {
    executar
    afirmar_jq "$A" 'any(.runs.steps[]; .id=="gerar" and .shell=="bash")' 'step com id: gerar e shell: bash'
    afirmar_jq "$A" '.runs.steps[] | select(.id=="gerar") | .env.NOME == "${{ inputs.nome }}"' 'NOME por env'
    afirmar_jq "$A" '.runs.steps[] | select(.id=="gerar") | .run | contains("${{") | not' 'o run não pode ter ${{ … }}'
}
teste_executa_e_gera_a_saida() {
    executar
    local script out; out="$(mktemp)"
    script="$(valor_jq "$A" '.runs.steps[] | select(.id=="gerar") | .run')"
    GITHUB_OUTPUT="$out" NOME="Ana" bash -c "$script" || _falhar "o run: do step falhou ao executar"
    afirmar_igual "mensagem=Olá, Ana" "$(cat "$out")"
}
