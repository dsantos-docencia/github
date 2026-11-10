# shellcheck shell=bash
# Testes do exercício 07.03 — Manual, agendado e à prova de injeção
W=.github/workflows/relatorio.yml
teste_cron_em_utc() {
    executar; afirmar_arquivo "$W"
    afirmar_jq "$W" '.on.schedule | length == 1' "exatamente um agendamento"
    afirmar_igual "0 11 * * 1" "$(valor_jq "$W" '.on.schedule[0].cron')" "08:00 em Brasília = 11:00 UTC, segunda = 1"
}
teste_input_dias() {
    executar
    afirmar_jq "$W" '.on.workflow_dispatch.inputs.dias.type == "number"'
    afirmar_jq "$W" '.on.workflow_dispatch.inputs.dias.default == 7' "default: 7 (número, sem aspas)"
}
teste_permissoes() {
    executar
    afirmar_jq "$W" '.permissions.contents == "read"'
}
teste_sem_expressao_no_run() {
    executar
    afirmar_jq "$W" '[.jobs[].steps[] | (.run // "") | contains("${{")] | any | not' \
        'nenhum run: pode conter ${{ … }} — passe por env:'
    afirmar_jq "$W" 'any(.jobs[].steps[]; (.env // {}) | to_entries | any(.value | tostring | contains("inputs.dias")))' \
        'algum step deve receber inputs.dias por env:'
}
teste_actionlint() { executar; afirmar_actionlint "$W"; }
