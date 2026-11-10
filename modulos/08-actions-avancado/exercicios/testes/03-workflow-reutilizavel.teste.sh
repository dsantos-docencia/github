# shellcheck shell=bash
# Testes do exercício 08.03 — Workflow reutilizável e quem o chama
R=.github/workflows/testes-reutilizavel.yml
C=.github/workflows/ci.yml
teste_reutilizavel() {
    executar; afirmar_arquivo "$R"
    afirmar_jq "$R" '.on.workflow_call.inputs."versao-node" | .type=="string" and .required==false and .default=="22"' \
        'input versao-node: type string, required false, default "22" (texto)'
    afirmar_jq "$R" '.permissions.contents == "read"'
    afirmar_jq "$R" 'any(.jobs.testes.steps[]; .with."node-version" == "${{ inputs.versao-node }}")'
    afirmar_jq "$R" '[.jobs.testes.steps[] | .uses // empty] | all(test("@[0-9a-f]{40}$"))' "todas as ações fixadas por SHA"
}
teste_chamador() {
    executar; afirmar_arquivo "$C"
    afirmar_jq "$C" '.jobs.testes.uses == "./.github/workflows/testes-reutilizavel.yml"'
    afirmar_jq "$C" '.jobs.testes.with."versao-node" == "24"' 'versao-node: "24" (texto, com aspas)'
    afirmar_jq "$C" '.permissions.contents == "read"'
}
teste_actionlint() {
    executar
    command -v actionlint >/dev/null || return 0
    actionlint -no-color -shellcheck= "$R" "$C" >/tmp/al.$$ 2>&1 || _falhar "actionlint encontrou problemas" "$(cat /tmp/al.$$)"
}
