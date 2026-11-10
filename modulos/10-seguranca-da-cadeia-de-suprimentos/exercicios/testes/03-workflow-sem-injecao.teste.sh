# shellcheck shell=bash
# Testes do exercício 10.03 — Boas-vindas sem injeção
W=.github/workflows/boas-vindas.yml
teste_evento() {
    executar; afirmar_arquivo "$W"
    afirmar_jq "$W" '.on.issues.types == ["opened"]'
    afirmar_jq "$W" '.on | has("pull_request_target") | not'
}
teste_permissoes_minimas() {
    executar
    afirmar_jq "$W" '.permissions == {}' "permissions: {} no topo"
    afirmar_jq "$W" '[.jobs[] | .permissions] == [{"issues":"write"}]' "no job: só issues: write"
}
teste_nada_de_expressao_no_run() {
    executar
    afirmar_jq "$W" '[.jobs[].steps[] | (.run // "") | contains("${{")] | any | not' 'nenhum run: com ${{ … }}'
    afirmar_jq "$W" 'any(.jobs[].steps[]; .env.GH_TOKEN == "${{ github.token }}")' "GH_TOKEN: \${{ github.token }} no env"
    afirmar_jq "$W" 'any(.jobs[].steps[]; (.env // {}) | to_entries | any(.value | tostring | contains("github.event.issue.title")))' "o título entra por env"
}
teste_titulo_malicioso_nao_executa() {
    executar
    local script; script="$(valor_jq "$W" '[.jobs[].steps[] | select(.run)][0].run')"
    export NUMERO=7 REPO=aluno/laboratorio AUTOR=visitante GH_TOKEN=ghs_ficticio
    export TITULO='x"; touch HACKEADO; echo "'
    bash -c "$script" >/dev/null 2>&1 || true
    [[ -e HACKEADO ]] && _falhar "o título malicioso executou um comando! use variáveis, não \${{ }}"
    afirmar_chamou_gh 'issue comment 7 -R aluno/laboratorio --body*' "o run deveria chamar gh issue comment \"\$NUMERO\" -R \"\$REPO\" --body …"
    afirmar_contem 'touch HACKEADO' "$(valor_opcao_gh 'issue comment*' --body)" "o título deve aparecer no comentário como texto"
}
teste_actionlint() { executar; afirmar_actionlint "$W"; }
