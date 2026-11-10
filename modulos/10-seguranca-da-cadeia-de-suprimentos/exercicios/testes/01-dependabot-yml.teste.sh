# shellcheck shell=bash
# Testes do exercício 10.01 — Dependabot com grupos e cooldown
Y=.github/dependabot.yml
acoes() { valor_jq "$Y" '.updates[] | select(."package-ecosystem"=="github-actions")'; }
teste_versao() {
    executar; afirmar_arquivo "$Y"
    afirmar_jq "$Y" '.version == 2'
    afirmar_jq "$Y" '.updates | length == 2' "exatamente duas entradas em updates"
}
teste_github_actions() {
    executar
    afirmar_jq "$Y" 'any(.updates[]; ."package-ecosystem"=="github-actions" and .directory=="/" and .schedule.interval=="weekly")'
    afirmar_jq "$Y" '.updates[] | select(."package-ecosystem"=="github-actions") | .groups.acoes.patterns == ["*"]' 'grupo acoes com patterns ["*"]'
}
teste_npm() {
    executar
    afirmar_jq "$Y" '.updates[] | select(."package-ecosystem"=="npm") | .directory=="/" and .schedule.interval=="weekly" and ."open-pull-requests-limit"==5'
    afirmar_jq "$Y" '.updates[] | select(."package-ecosystem"=="npm") | .cooldown."default-days" == 7' "cooldown.default-days: 7"
    afirmar_jq "$Y" '.updates[] | select(."package-ecosystem"=="npm") | .groups.dev."dependency-type" == "development"'
}
