# shellcheck shell=bash
teste_tres_secoes() {
    simular_gh 'search prs*' '[{"number":7,"title":"feat: login","repository":{"nameWithOwner":"aluno/loja"},"updatedAt":"2026-11-02T10:00:00Z"}]'
    simular_gh 'search issues*' '[]'
    executar
    afirmar_status 0
    afirmar_contem "👀 Revisões pedidas a você (1)" "$SAIDA"
    afirmar_contem "  aluno/loja#7  feat: login" "$SAIDA"
    afirmar_contem "📌 Issues atribuídos a você (0)" "$SAIDA"
    afirmar_chamou_gh 'search prs --review-requested=@me --state=open*'
    afirmar_chamou_gh 'search issues --assignee=@me --state=open*'
}
teste_filtro_de_org() {
    simular_gh 'search *' '[]'
    executar --org minha-org
    afirmar_igual "3" "$(contar_chamadas_gh 'search *--owner minha-org*')" "as três buscas filtradas pela organização"
}
