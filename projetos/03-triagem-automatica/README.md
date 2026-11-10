# Projeto 03 · Triagem automática de issues

**Problema:** issues chegam sem label, ninguém responde a quem chega pela primeira vez, e de vez em quando alguém descreve uma vulnerabilidade **em público**.

**Solução:** um workflow ([`triagem.yml`](triagem.yml)) disparado quando um issue é aberto roda [`triagem.sh`](triagem.sh), que:

1. lê o evento (`$GITHUB_EVENT_PATH`) com `jq`;
2. aplica labels por palavras-chave — `bug`, `documentação`, `segurança`, `pergunta` (ou `triagem`, se nada casar) — numa única chamada;
3. dá boas-vindas a quem contribui pela primeira vez (`author_association`);
4. em relatos que parecem de segurança, orienta a usar o **relato privado** (Módulo 10).

**Segurança por construção:** o workflow usa `issues` (não `pull_request_target`), `permissions: {}` no topo e só `issues: write` no job, faz checkout apenas da pasta do script (da branch padrão) e o script **nunca executa** o texto do issue — há um teste que tenta exatamente isso.

```bash
# testar localmente com um evento falso e o gh simulado:
./ferramentas/verificar-tudo.sh      # etapa 5
```

**Para instalar no seu repositório:** copie `triagem.yml` para `.github/workflows/` e `triagem.sh` para `.github/scripts/`, crie os labels (exercício 03.02) e abra um issue no seu laboratório.

**Desafios para ir além**
1. Leia as regras de palavra-chave de um arquivo `.github/triagem.yml` versionado, em vez de deixá-las no script.
2. Atribua automaticamente com base no CODEOWNERS da área mencionada.
3. Em vez de token do workflow, use um **GitHub App** (Módulo 11) para que o comentário apareça como `app[bot]`.
