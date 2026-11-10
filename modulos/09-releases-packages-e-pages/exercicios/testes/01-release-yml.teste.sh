# shellcheck shell=bash
# Testes do exercício 09.01 — Categorias das notas de release
Y=.github/release.yml
teste_exclusoes() {
    executar; afirmar_arquivo "$Y"
    afirmar_jq "$Y" '.changelog.exclude.labels == ["ignorar-nas-notas"]'
    afirmar_jq "$Y" '.changelog.exclude.authors == ["dependabot"]'
}
teste_categorias_em_ordem() {
    executar
    afirmar_jq "$Y" '[.changelog.categories[].title] == ["🚀 Novidades","🐛 Correções","Outras mudanças"]' "três categorias, nesta ordem e com estes títulos"
    afirmar_jq "$Y" '.changelog.categories[0].labels == ["feature","melhoria"]'
    afirmar_jq "$Y" '.changelog.categories[1].labels == ["bug"]'
}
teste_coringa_por_ultimo() {
    executar
    afirmar_jq "$Y" '.changelog.categories[-1].labels == ["*"]' 'a última categoria deve ter labels: ["*"]'
}
