# shellcheck shell=bash
# Testes do exercício 11.03 — Todos os repositórios ativos de uma organização
teste_lista_ativos_ordenados() {
    executar aluno
    afirmar_status 0
    afirmar_igual $'aluno/laboratorio\naluno/site-pessoal\ntotal: 2' "$SAIDA"
}
teste_pagina_tudo() {
    executar minha-org
    afirmar_chamou_gh "api --paginate 'orgs/minha-org/repos?per_page=100'*" "use --paginate e per_page=100 na URL"
}
teste_ordem_alfabetica() {
    simular_gh 'api *orgs/*/repos*' '[{"full_name":"o/zeta","archived":false},{"full_name":"o/alfa","archived":false},{"full_name":"o/meio","archived":true}]'
    executar o
    afirmar_igual $'o/alfa\no/zeta\ntotal: 2' "$SAIDA"
}
teste_org_vazia() {
    simular_gh 'api *orgs/*/repos*' '[]'
    executar vazia
    afirmar_igual "total: 0" "$SAIDA"
}
teste_sem_argumento() { executar; afirmar_status 2; }
