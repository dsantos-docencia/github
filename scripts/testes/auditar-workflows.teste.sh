# shellcheck shell=bash
teste_workflow_seguro() {
    mkdir -p wf; cp "$(dirname "$ALVO")/../../modulos/10-seguranca-da-cadeia-de-suprimentos/exemplos/workflows/boas-vindas-seguro.yml" wf/
    executar wf
    afirmar_status 0; afirmar_contem "0 achado(s)" "$SAIDA"
}
teste_workflow_perigoso() {
    mkdir -p wf
    cat > wf/ruim.yml <<YAML
on: pull_request_target
jobs:
  a:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "\${{ github.event.pull_request.title }}"
      - name: bloco
        run: |
          echo ok
          echo "\${{ github.head_ref }}"
      - run: echo "\${{ github.sha }}"
YAML
    executar wf
    afirmar_status 1
    afirmar_contem "ALTO   ruim.yml: usa pull_request_target" "$SAIDA"
    afirmar_contem "ALTO   ruim.yml:7:" "$SAIDA" "injeção na linha 7 (run de uma linha)"
    afirmar_contem "ALTO   ruim.yml:11:" "$SAIDA" "injeção na linha 11 (dentro do bloco run: |)"
    afirmar_nao_contem "ruim.yml:12:" "$SAIDA" "github.sha não é dado do usuário"
    afirmar_contem "MÉDIO  ruim.yml: sem 'permissions:'" "$SAIDA"
    afirmar_contem "MÉDIO  ruim.yml:6: actions/checkout@v4 sem SHA fixo" "$SAIDA"
    afirmar_contem "BAIXO  ruim.yml: checkout sem persist-credentials" "$SAIDA"
}
teste_env_e_seguro() {
    mkdir -p wf
    printf 'on: issues\npermissions: {}\njobs:\n  a:\n    runs-on: ubuntu-latest\n    steps:\n      - env:\n          T: ${{ github.event.issue.title }}\n        run: echo "$T"\n' > wf/ok.yml
    executar wf
    afirmar_status 0 "título por env não é injeção"
}
teste_pasta_inexistente() { executar nao-existe; afirmar_status 2; }
