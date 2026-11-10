# 🏋️ Exercícios — Módulo 02

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 02        # todos do módulo
./ferramentas/corrigir.sh 02 01     # só o exercício 01
```

Os exercícios treinam publicar um projeto, configurar o repositório e gerar relatórios a partir do `gh`.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Publicar um projeto novo · `01-publicar-projeto.sh`
O script deve:
1. criar o repositório local `site` (branch `main`) com um `README.md` (qualquer conteúdo) e um `.gitignore` contendo as linhas `node_modules/` e `.env`;
2. fazer o commit `chore: estrutura inicial` com os dois arquivos;
3. publicar com **uma** chamada a `gh repo create` que use: o nome `site`, `--private`, `--source site`, `--remote origin` e `--description "Site da Loja do Bairro"`.

O `gh` é simulado: o corretor confere a chamada registrada.

### 02 — Configurar o repositório pelo terminal · `02-configurar-repositorio.sh`
O script recebe `dono/repo` em `$1` e faz **uma** chamada `gh repo edit "$1"` que:
- adiciona os tópicos `curso` e `github` (`--add-topic`);
- desliga o merge commit (`--enable-merge-commit=false`) e liga squash (`--enable-squash-merge`);
- liga a exclusão automática de branches mescladas (`--delete-branch-on-merge`);
- desliga a wiki (`--enable-wiki=false`).

Sem argumento, ou com algo que não tenha o formato `dono/repo`, saia com **2** e uma mensagem de uso em stderr, **sem** chamar o `gh`.

### 03 — Inventário dos repositórios de uma conta · `03-inventario-de-repos.sh`
O script recebe um dono (usuário ou organização) em `$1` e, com **uma** chamada a
`gh repo list "$1" --limit 1000 --json name,isPrivate,isArchived`, imprime exatamente três linhas:

```
públicos: N
privados: N
arquivados: N
```

“Arquivados” conta repositórios arquivados de qualquer visibilidade (um repositório pode ser público **e** arquivado). Com os dados de exemplo do simulador (`laboratorio` privado; `site-pessoal` público; `projeto-antigo` público e arquivado), a saída é `2`, `1`, `1`.

Dica: `--jq` com `map(select(...)) | length`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
