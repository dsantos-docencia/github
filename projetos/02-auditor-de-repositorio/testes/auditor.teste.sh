# shellcheck shell=bash
# Testes do Projeto 02 — auditor de repositório (dados do gh simulado)
teste_relatorio_padrao() {
    executar aluno/laboratorio
    afirmar_status 0 "nota 8 com mínimo padrão 8"
    afirmar_contem "✔ descrição preenchida" "$SAIDA"
    afirmar_contem "✘ saúde da comunidade ≥ 80%" "$SAIDA" "a comunidade de exemplo está em 71%"
    afirmar_contem "✘ no máximo 1 admin" "$SAIDA" "o ex-estagiário ainda é admin nos dados de exemplo"
    afirmar_igual "nota: 8/10" "$(tail -1 <<<"$SAIDA")"
}
teste_minimo() {
    executar aluno/laboratorio --minimo 9
    afirmar_status 1 "nota 8 < mínimo 9"
}
teste_json() {
    executar aluno/laboratorio --json
    jq -e '.nota == 8 and .total == 10 and (.itens | length) == 10' <<<"$SAIDA" >/dev/null || _falhar "JSON inesperado" "$SAIDA"
    jq -e '.itens[] | select(.item == "admins") | .ok == false' <<<"$SAIDA" >/dev/null || _falhar "item admins deveria ser false"
}
teste_dependabot_desligado() {
    simular_gh 'api repos/*/vulnerability-alerts*' '{"message":"Not Found"}' 1
    executar aluno/laboratorio
    afirmar_contem "✘ alertas do Dependabot ligados" "$SAIDA"
}
teste_usa_a_branch_padrao() {
    simular_gh 'api repos/aluno/outro' '{"description":"x","default_branch":"trunk","topics":[]}'
    executar aluno/outro
    afirmar_chamou_gh 'api repos/aluno/outro/rules/branches/trunk*' "consulte as regras da branch padrão (trunk), não 'main'"
}
teste_somente_leitura() {
    executar aluno/laboratorio
    afirmar_nao_chamou_gh 'api -X *' "o auditor não pode alterar nada"
}
teste_argumento_invalido() {
    executar
    afirmar_status 2
    executar aluno
    afirmar_status 2
}
