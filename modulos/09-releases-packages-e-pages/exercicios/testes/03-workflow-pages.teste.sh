# shellcheck shell=bash
# Testes do exercício 09.03 — Workflow de publicação no Pages
W=.github/workflows/pages.yml
teste_eventos_e_permissoes() {
    executar; afirmar_arquivo "$W"
    afirmar_jq "$W" '.on.push.branches == ["main"] and (.on | has("workflow_dispatch"))'
    afirmar_jq "$W" '.permissions == {"contents":"read","pages":"write","id-token":"write"}' "permissões exatamente: contents read, pages write, id-token write"
    afirmar_jq "$W" '.concurrency.group == "pages" and .concurrency."cancel-in-progress" == false'
}
teste_build() {
    executar
    afirmar_jq "$W" 'any(.jobs.build.steps[]; (.uses // "") | startswith("actions/configure-pages@"))'
    afirmar_jq "$W" 'any(.jobs.build.steps[]; ((.uses // "") | startswith("actions/upload-pages-artifact@")) and .with.path == "_site")' "upload-pages-artifact com path: _site"
}
teste_deploy() {
    executar
    afirmar_jq "$W" '.jobs.deploy.needs == "build" or .jobs.deploy.needs == ["build"]'
    afirmar_jq "$W" '.jobs.deploy.environment.name == "github-pages"'
    afirmar_jq "$W" '.jobs.deploy.environment.url == "${{ steps.deploy.outputs.page_url }}"'
    afirmar_jq "$W" 'any(.jobs.deploy.steps[]; .id == "deploy" and ((.uses // "") | startswith("actions/deploy-pages@")))'
}
teste_tudo_por_sha() {
    executar
    afirmar_jq "$W" '[.jobs[].steps[] | .uses // empty] | length > 0 and all(test("@[0-9a-f]{40}$"))' "todas as ações fixadas por SHA de 40 caracteres"
}
teste_actionlint() { executar; afirmar_actionlint "$W"; }
