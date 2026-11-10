# Projeto 01 · Kit de repositório

**Problema:** todo repositório novo do time começa “pelado” — sem licença, sem template, sem CI, sem CODEOWNERS — e cada um é configurado de um jeito.

**Solução:** [`kit.sh`](kit.sh) instala, em um comando, tudo o que os Módulos 03, 04, 05, 07 e 10 ensinaram: arquivos de saúde da comunidade, issue form, template de PR, CODEOWNERS, Dependabot e um workflow de CI endurecido (ação fixada por SHA, permissões mínimas).

```bash
./projetos/01-kit-de-repositorio/kit.sh ~/projetos/loja --dono @bia-dev --licenca mit
./projetos/01-kit-de-repositorio/kit.sh ~/projetos/loja            # de novo: nada é sobrescrito
./projetos/01-kit-de-repositorio/kit.sh ~/projetos/loja --forcar   # reescreve tudo
```

**Conceitos praticados:** idempotência (rodar duas vezes = rodar uma), API de licenças, here-docs, validação do que foi gerado.

**Desafios para ir além**
1. Adicione `--sem-ci` e `--linguagem node|python` (gerando o `dependabot.yml` e o CI certos para cada uma).
2. Ao final, se a pasta for um repositório Git, crie um commit `chore: kit de repositório`.
3. Transforme-o em **repositório template** no GitHub e compare as duas abordagens (Módulo 02).

```bash
./ferramentas/verificar-tudo.sh     # roda os testes deste projeto (etapa 5)
```
