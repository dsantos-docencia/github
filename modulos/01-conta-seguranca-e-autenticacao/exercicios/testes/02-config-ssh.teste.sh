# shellcheck shell=bash
# Testes do exercício 01.02 — Um config SSH à prova de firewall
# Lê o valor de OPÇÃO dentro do bloco "Host NOME" (como o ssh faria, simplificado).
opcao() {
    awk -v h="$1" -v o="$2" '
        tolower($1)=="host" { dentro = ($2 == h); next }
        dentro && tolower($1)==tolower(o) { $1=""; sub(/^ /,""); print; exit }' ssh/config
}
teste_arquivo_existe() {
    executar; afirmar_arquivo ssh/config
}
teste_bloco_github() {
    executar
    afirmar_igual "github.com" "$(opcao github.com HostName)"
    afirmar_igual "git" "$(opcao github.com User)"
    # shellcheck disable=SC2088  # queremos o ~ LITERAL: quem expande é o ssh
    afirmar_igual "~/.ssh/id_ed25519_github" "$(opcao github.com IdentityFile)" "o ~ deve ficar literal no arquivo"
    afirmar_igual "yes" "$(opcao github.com IdentitiesOnly)"
    afirmar_igual "yes" "$(opcao github.com AddKeysToAgent)"
}
teste_bloco_443() {
    executar
    afirmar_igual "ssh.github.com" "$(opcao github-443 HostName)"
    afirmar_igual "443" "$(opcao github-443 Port)"
    afirmar_igual "git" "$(opcao github-443 User)"
}
teste_permissao_600() {
    executar
    afirmar_igual "600" "$(stat -c %a ssh/config 2>/dev/null || stat -f %Lp ssh/config)"
}
teste_ssh_aceita_o_arquivo() {
    executar
    command -v ssh >/dev/null || return 0   # sem cliente ssh, pulamos esta checagem
    ssh -G -F ssh/config github-443 >/dev/null 2>&1 || _falhar "o ssh não conseguiu ler o arquivo (erro de sintaxe?)"
}
