# shellcheck shell=bash
# Testes do Projeto 01 — kit de repositório
ARQS=(README.md LICENSE CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md
      .github/ISSUE_TEMPLATE/bug.yml .github/ISSUE_TEMPLATE/config.yml
      .github/pull_request_template.md .github/CODEOWNERS .github/dependabot.yml .github/workflows/ci.yml)
teste_cria_tudo_numa_pasta_vazia() {
    mkdir proj; executar proj --dono @ana
    afirmar_status 0
    local a; for a in "${ARQS[@]}"; do afirmar_arquivo "proj/$a"; done
    afirmar_contem "11 criados, 0 mantidos" "$SAIDA"
}
teste_idempotente() {
    mkdir proj; executar proj --dono @ana; executar proj --dono @ana
    afirmar_status 0
    afirmar_contem "0 criados, 11 mantidos" "$SAIDA" "a segunda execução não pode sobrescrever nada"
}
teste_mantem_readme_existente() {
    mkdir proj; printf '# Meu README\n' > proj/README.md
    executar proj --dono @ana
    afirmar_igual "# Meu README" "$(cat proj/README.md)"
    afirmar_contem "· mantido  README.md" "$SAIDA"
}
teste_forcar_sobrescreve() {
    mkdir proj; printf '# Meu README\n' > proj/README.md
    executar proj --dono @ana --forcar
    afirmar_nao_contem "Meu README" "$(cat proj/README.md)"
}
teste_dono_no_codeowners() {
    mkdir proj; executar proj --dono bia-dev
    afirmar_igual "* @bia-dev" "$(grep -v '^#' proj/.github/CODEOWNERS | head -1 | awk '{$1=$1;print}')" "aceita o dono com ou sem @"
}
teste_licenca_pela_api() {
    mkdir proj; executar proj --dono @ana --licenca mit
    afirmar_chamou_gh 'api licenses/mit*'
    afirmar_contem "Copyright (c) $(date +%Y) ana" "$(cat proj/LICENSE)"
}
teste_dono_padrao_vem_da_api() {
    mkdir proj; executar proj
    afirmar_chamou_gh 'api user*'
    afirmar_contem "@aluno" "$(cat proj/.github/CODEOWNERS)"
}
teste_yaml_e_workflow_validos() {
    mkdir proj; executar proj --dono @ana
    afirmar_jq proj/.github/ISSUE_TEMPLATE/bug.yml '.labels == ["bug"]'
    afirmar_jq proj/.github/workflows/ci.yml '.permissions.contents == "read"'
    afirmar_actionlint proj/.github/workflows/ci.yml
}
teste_pasta_inexistente() {
    executar nao-existe
    afirmar_status 2
}
