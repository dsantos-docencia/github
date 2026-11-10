# shellcheck shell=bash
# Testes do exercício 07.01 — Um workflow de CI correto
W=.github/workflows/ci.yml
teste_arquivo() { executar; afirmar_arquivo "$W"; }
teste_nome_e_eventos() {
    executar
    afirmar_jq "$W" '.name == "CI"'
    afirmar_jq "$W" '.on.push.branches == ["main"]' "on.push.branches deve ser [main]"
    afirmar_jq "$W" '.on | has("pull_request")' "falta o evento pull_request"
}
teste_permissoes_minimas() {
    executar
    afirmar_jq "$W" '.permissions.contents == "read"' "declare permissions: contents: read no topo"
}
teste_job() {
    executar
    afirmar_jq "$W" '.jobs.testes."runs-on" == "ubuntu-latest"' "job testes com runs-on: ubuntu-latest"
    afirmar_jq "$W" '(.jobs.testes."timeout-minutes" | type) == "number" and .jobs.testes."timeout-minutes" <= 15' "timeout-minutes numérico e ≤ 15"
}
teste_checkout_por_sha() {
    executar
    afirmar_jq "$W" '.jobs.testes.steps[0].uses | test("^actions/checkout@[0-9a-f]{40}$")' "o 1º step deve ser actions/checkout@<SHA de 40 caracteres>"
}
teste_roda_os_testes() {
    executar
    afirmar_jq "$W" 'any(.jobs.testes.steps[]; (.run // "") | contains("./testes.sh"))' "falta um step com run: ./testes.sh"
}
teste_actionlint() { executar; afirmar_actionlint "$W"; }
