# shellcheck shell=bash
# Testes do exercício 03.01 — Um formulário de bug que não aceita relato pela metade
B=.github/ISSUE_TEMPLATE/bug.yml
teste_arquivos_existem() {
    executar
    afirmar_arquivo "$B"; afirmar_arquivo .github/ISSUE_TEMPLATE/config.yml
}
teste_cabecalho() {
    executar
    afirmar_jq "$B" '.name == "Relatar um bug"' "name: Relatar um bug"
    afirmar_jq "$B" '(.description | type) == "string" and (.description | length) > 0' "falta description"
    afirmar_jq "$B" '.labels == ["bug"]' 'labels: ["bug"]'
}
teste_passos_obrigatorio() {
    executar
    afirmar_jq "$B" 'any(.body[]; .type=="textarea" and .id=="passos")' "falta textarea com id passos"
    afirmar_jq "$B" 'any(.body[]; .id=="passos" and .validations.required==true)' "passos precisa de validations.required: true"
    afirmar_jq "$B" 'any(.body[]; .id=="passos" and (.attributes.label|length)>0)' "passos precisa de attributes.label"
}
teste_gravidade() {
    executar
    afirmar_jq "$B" 'any(.body[]; .type=="dropdown" and .id=="gravidade" and .attributes.options==["Baixa","Média","Alta"])' \
        "dropdown gravidade com opções Baixa, Média, Alta (nesta ordem)"
}
teste_logs_shell() {
    executar
    afirmar_jq "$B" 'any(.body[]; .type=="textarea" and .id=="logs" and .attributes.render=="shell")' "textarea logs com render: shell"
}
teste_ordem() {
    executar
    afirmar_jq "$B" '[.body[].id // empty] | (index("passos") < index("gravidade")) and (index("gravidade") < index("logs"))' \
        "a ordem deve ser passos → gravidade → logs"
}
teste_sem_issue_em_branco() {
    executar
    afirmar_jq .github/ISSUE_TEMPLATE/config.yml '.blank_issues_enabled == false'
}
