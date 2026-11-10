# shellcheck shell=bash
# Testes do exercício 06.01 — Um ruleset completo em JSON
R=ruleset-main.json
teste_json_valido() {
    executar; afirmar_arquivo "$R"
    jq empty "$R" 2>/dev/null || _falhar "JSON inválido — rode: jq . $R"
}
teste_cabecalho() {
    executar
    afirmar_jq "$R" '.name=="proteger-main" and .target=="branch" and .enforcement=="active"'
    afirmar_jq "$R" '.conditions.ref_name.include==["~DEFAULT_BRANCH"] and .conditions.ref_name.exclude==[]' "condições: include [~DEFAULT_BRANCH], exclude []"
}
teste_regras_basicas() {
    executar
    afirmar_jq "$R" 'any(.rules[]; .type=="deletion")' "falta a regra deletion"
    afirmar_jq "$R" 'any(.rules[]; .type=="non_fast_forward")' "falta a regra non_fast_forward"
}
teste_pull_request_completo() {
    executar
    afirmar_jq "$R" '.rules[] | select(.type=="pull_request") | .parameters
        | .required_approving_review_count==1 and .dismiss_stale_reviews_on_push==true
          and .require_code_owner_review==true and .require_last_push_approval==false
          and .required_review_thread_resolution==true' "pull_request precisa dos 5 parâmetros com os valores pedidos (booleanos sem aspas!)"
}
teste_check_obrigatorio() {
    executar
    afirmar_jq "$R" '.rules[] | select(.type=="required_status_checks") | .parameters
        | .strict_required_status_checks_policy==true and .required_status_checks==[{"context":"verificar"}]'
}
