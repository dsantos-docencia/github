# shellcheck shell=bash
teste_exporta() {
    simular_gh 'issue list*' "$(cat "$(dirname "$ALVO")/../../ferramentas/simulador/respostas/issue-list-todas.json")"
    executar aluno/laboratorio bkp
    afirmar_status 0
    afirmar_igual "5" "$(jq length bkp/issues.json)"
    afirmar_contem "5 issues exportados para bkp/" "$SAIDA"
    afirmar_chamou_gh 'issue list -R aluno/laboratorio --state all*'
}
teste_indice_markdown() {
    simular_gh 'issue list*' '[{"number":2,"title":"A | B","state":"CLOSED","labels":[{"name":"bug"}],"author":{"login":"ana"},"url":"u2"},{"number":1,"title":"X","state":"OPEN","labels":[],"author":{"login":"bia"},"url":"u1"}]'
    executar a/b bkp
    afirmar_igual "| [1](u1) | open | X |  | @bia |" "$(sed -n 5p bkp/issues.md)" "ordenado por número"
    afirmar_contem 'A \| B' "$(cat bkp/issues.md)" "o | no título precisa ser escapado na tabela"
}
teste_limite_alto() {
    executar a/b bkp
    afirmar_igual "100000" "$(valor_opcao_gh 'issue list*' --limit)" "sem --limit alto, só viriam 30"
}
teste_uso() { executar; afirmar_status 2; }
