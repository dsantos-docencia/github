# shellcheck shell=bash
# Testes do exercício 02.01 — Publicar um projeto novo
teste_repositorio_local() {
    executar
    afirmar_igual "chore: estrutura inicial" "$(git -C site log -1 --format=%s 2>/dev/null)"
    afirmar_igual $'.gitignore\nREADME.md' "$(git -C site ls-tree --name-only HEAD)" "o commit deve ter exatamente README.md e .gitignore"
}
teste_gitignore() {
    executar
    grep -qx 'node_modules/' site/.gitignore || _falhar ".gitignore sem a linha node_modules/"
    grep -qx '.env' site/.gitignore || _falhar ".gitignore sem a linha .env"
}
teste_chamou_repo_create() {
    executar
    afirmar_igual "1" "$(contar_chamadas_gh 'repo create*')" "chame gh repo create exatamente uma vez"
}
teste_opcoes_do_repo_create() {
    executar
    afirmar_chamou_gh 'repo create site *' "o primeiro argumento deve ser o nome: site"
    afirmar_chamou_gh 'repo create*--private*' "falta --private"
    afirmar_igual "site" "$(valor_opcao_gh 'repo create*' --source)" "--source site"
    afirmar_igual "origin" "$(valor_opcao_gh 'repo create*' --remote)" "--remote origin"
    afirmar_igual "Site da Loja do Bairro" "$(valor_opcao_gh 'repo create*' --description)"
}
teste_commit_antes_de_publicar() {
    executar
    afirmar_nao_chamou_gh 'repo create*--public*' "o repositório deve ser privado"
}
