# 🏋️ Exercícios — Módulo 04

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 04        # todos do módulo
./ferramentas/corrigir.sh 04 01     # só o exercício 01
```

Os exercícios treinam CODEOWNERS, template de PR e abrir um PR completo a partir do terminal.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — CODEOWNERS na ordem certa · `01-codeowners.sh`
Crie `.github/CODEOWNERS` com estas regras (o arquivo pode ter comentários e linhas vazias):

| Padrão | Donos |
|---|---|
| `*` | `@aluno` |
| `*.js` | `@bia-dev` |
| `/docs/` | `@org/documentacao` |
| `/.github/` | `@aluno` e `@org/plataforma` |

Lembre: **a última regra que casar vence**. O padrão geral (`*`) precisa ser a **primeira** regra, senão ele anula as outras.

### 02 — Template de pull request · `02-template-de-pr.sh`
Crie `.github/pull_request_template.md` com:
- as seções (títulos de nível 2) **`## O que muda`**, **`## Por quê`** e **`## Como testar`**, nesta ordem;
- uma seção `## Checklist` com **pelo menos 3** itens de tarefa desmarcados (`- [ ] ...`);
- uma linha lembrando de ligar o issue, contendo `Closes #` (por exemplo `Closes #`  dentro de um comentário HTML `<!-- -->` ou em texto).

### 03 — Abrir um PR completo pelo terminal · `03-abrir-pr.sh`
Os testes criam o repositório `app` (com `origin` apontando para um repositório bare) e deixam você **na branch `feature/frete`**, que tem commits ainda não publicados. O script recebe o número de um issue em `$1` e deve, a partir da pasta atual (entre em `app`):

1. publicar a branch atual no `origin` **ligando o upstream** (`git push -u`);
2. abrir o PR com `gh pr create` usando:
   - `--base main` e `--head <branch atual>` (descubra o nome; não escreva fixo),
   - `--title` igual ao **assunto do último commit**,
   - `--body` contendo a linha `Closes #<número recebido>`,
   - `--draft`.

Sem `$1` (ou não numérico) → saída **2**, sem publicar nada.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
