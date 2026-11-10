# shellcheck shell=bash
teste_lista_por_papel() {
    executar aluno/laboratorio
    afirmar_status 0
    afirmar_contem "admin     aluno, ex-estagiario" "$SAIDA"
    afirmar_contem "write     bia-dev" "$SAIDA"
    afirmar_contem "triage    caio-qa" "$SAIDA"
    afirmar_contem "⚠ 2 admins" "$SAIDA"
}
teste_pagina() {
    executar aluno/laboratorio
    afirmar_chamou_gh "api --paginate 'repos/aluno/laboratorio/collaborators?per_page=100'"
}
teste_json() {
    executar aluno/laboratorio --json
    jq -e '.total == 4 and .por_papel.admin == ["aluno","ex-estagiario"]' <<<"$SAIDA" >/dev/null || _falhar "JSON inesperado" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; }
