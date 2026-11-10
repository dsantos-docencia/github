# Módulo 03 · Issues, labels, milestones e Projects

> **Você vai sair daqui sabendo:** escrever e triar issues que alguém consegue resolver, organizar com labels, milestones, tipos e sub-issues, criar **issue forms** que obrigam o relato a vir completo, buscar como um profissional, ligar issues a PRs que as fecham sozinhas e planejar com **Projects** — tudo também pelo `gh`.

⏱ 4–5 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

O site da loja foi ao ar e os relatos chegam por WhatsApp, e-mail, de boca: “tá dando erro”, “o botão sumiu”. Sem um lugar único, coisas se perdem e ninguém sabe o que é prioridade. **Issues** são esse lugar: cada problema ou ideia vira um item com número, histórico, responsável e estado.

## 2. Anatomia de um bom issue

| Parte | Ruim | Bom |
|---|---|---|
| Título | “erro” | “Erro 500 ao salvar o perfil com foto acima de 5 MB” |
| Passos | — | 1. Entrar 2. Perfil → Foto 3. Enviar `foto.png` (6 MB) 4. Salvar |
| Esperado × obtido | “não funciona” | esperado: mensagem “máx. 5 MB”; obtido: página de erro 500 |
| Ambiente | — | Chrome 140, Android 15, versão v1.1.0 |
| Evidência | — | print, trecho do log (sem senhas!) |

> 🧠 **O teste do issue bom:** alguém que nunca viu o problema consegue reproduzi-lo só com o que está escrito?

## 3. Organizando

| Ferramenta | Para quê | Exemplo |
|---|---|---|
| **Labels** | categorias livres, com cor | `bug`, `melhoria`, `good first issue`, `prioridade:alta` |
| **Milestones** | agrupar por entrega/data | `v1.1` (vence em 30/11) |
| **Assignees** | quem está cuidando | `@bia-dev` |
| **Issue types** | o *tipo* do item, definido pela organização | Bug, Feature, Task |
| **Sub-issues** | quebrar um issue grande em partes, com progresso | “Checkout” → “Pix”, “Cartão”, “Boleto” |
| **Menções** | chamar alguém ou um time | `@caio-qa`, `@org/suporte` |
| **Referências** | ligar trabalhos | `#12`, `aluno/outro#3`, um SHA |

### Fechando issues pelo PR

Escreva na **descrição do PR** (ou numa mensagem de commit que chegue à branch padrão):

```
Closes #12        Fixes #12        Resolves #12      (e as variações close, fixed, resolve…)
```

Quando o PR é mesclado **na branch padrão**, o issue fecha sozinho e fica ligado ao PR — a rastreabilidade sai de graça.

## 4. Issue forms: o relato já chega completo

Templates ficam em `.github/ISSUE_TEMPLATE/`. Os **forms** (YAML) viram formulários de verdade, com campos obrigatórios:

```yaml
# .github/ISSUE_TEMPLATE/bug.yml
name: 🐛 Relatar um bug
description: Algo não funciona como deveria
labels: ["bug"]
body:
  - type: textarea
    id: passos
    attributes:
      label: Passos para reproduzir
      placeholder: "1. ...\n2. ..."
    validations:
      required: true
  - type: dropdown
    id: gravidade
    attributes:
      label: Gravidade
      options: [Baixa, Média, Alta]
```

```yaml
# .github/ISSUE_TEMPLATE/config.yml
blank_issues_enabled: false          # obriga a usar um formulário
contact_links:
  - name: 💬 Dúvidas
    url: https://github.com/aluno/loja/discussions
    about: Perguntas vão para as Discussions, não para issues.
```

Tipos de campo: `markdown` (texto fixo), `input`, `textarea` (com `render: shell` para logs), `dropdown`, `checkboxes`. Este próprio repositório usa forms — veja [`.github/ISSUE_TEMPLATE/`](../../.github/ISSUE_TEMPLATE/).

## 5. Buscando como profissional

A busca usa qualificadores — na caixa de busca do site, em `gh issue list --search` e em `gh search issues`:

| Busca | Encontra |
|---|---|
| `is:issue is:open label:bug no:assignee` | bugs abertos sem dono — a fila de triagem |
| `is:open sort:updated-asc` | o que está parado há mais tempo |
| `is:issue author:@me` / `assignee:@me` / `mentions:@me` | o que é seu |
| `milestone:v1.1 is:open` | o que falta para a entrega |
| `label:"good first issue" language:python is:open` | onde começar a contribuir |
| `created:>2026-10-01 -label:duplicada` | período, excluindo um label |

## 6. Issues pelo terminal

```bash
gh issue create -R aluno/loja --title "Erro 500 ao salvar perfil" --body-file relato.md --label bug --assignee @me
gh issue list --label bug --state open --limit 50
gh issue list --search "no:assignee sort:created-asc" --json number,title --jq '.[] | "#\(.number) \(.title)"'
gh issue view 12 --comments
gh issue edit 12 --add-label prioridade:alta --milestone v1.1
gh issue comment 12 --body "Reproduzido na v1.1.0."
gh issue close 12 --reason "not planned" --comment "Duplicado de #9"
gh issue develop 12 --checkout          # cria uma branch ligada ao issue e entra nela
gh label create "prioridade:alta" --color d93f0b --description "Resolver nesta semana" --force
```

## 7. Discussions × issues

| Use **Issues** para | Use **Discussions** para |
|---|---|
| trabalho acionável: bug, tarefa, melhoria aceita | perguntas, ideias em aberto, anúncios, “como faço…?” |
| algo que vai ser **fechado** por um PR | conversa que pode nunca “terminar” |

## 8. Projects: planejamento em cima dos issues

**Projects** são planilhas/quadros que reúnem issues e PRs de **vários repositórios**, com campos próprios (Status, Prioridade, Estimativa, Iteração) e visões (tabela, quadro, roteiro). Automações embutidas movem cartões: issue fechado → *Done*; PR mesclado → *Done*.

```bash
gh auth refresh -s project                       # o escopo project é pedido à parte
gh project create --owner @me --title "Loja — Sprint 1"
gh project item-add 1 --owner @me --url https://github.com/aluno/loja/issues/12
gh project item-list 1 --owner @me --format json --jq '.items[].title'
```

## 9. Armadilhas comuns

- **Label demais.** Vinte labels que ninguém usa = nenhum label. Comece com 6–8 e revise.
- **Issue “Melhorar o sistema”.** Sem critério de pronto, nunca fecha. Quebre em sub-issues.
- **`Closes #12` no título do PR** em vez da descrição — no título não funciona.
- **`Closes #12` num PR para outra branch** que não a padrão: o issue só fecha quando a mudança chega na branch padrão.
- **Dados pessoais e segredos em issues públicos** (prints com CPF, logs com token). Issue público é página pública.

## 📚 Fontes oficiais

- Sobre issues: <https://docs.github.com/pt/issues/tracking-your-work-with-issues/about-issues>
- Sub-issues: <https://docs.github.com/pt/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues>
- Vincular PR a issue (palavras-chave): <https://docs.github.com/pt/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue>
- Sintaxe de issue forms: <https://docs.github.com/pt/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms>
- Configurar templates (config.yml): <https://docs.github.com/pt/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository>
- Sintaxe de busca de issues e PRs: <https://docs.github.com/pt/search-github/searching-on-github/searching-issues-and-pull-requests>
- Sobre Projects: <https://docs.github.com/pt/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects>
- `gh issue` / `gh label` / `gh project`: <https://cli.github.com/manual/gh_issue>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
