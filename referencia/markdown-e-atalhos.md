# Markdown, atalhos e truques de URL

## Markdown do GitHub (GFM)

| Quero | Escrevo |
|---|---|
| título | `# H1` · `## H2` · `### H3` |
| ênfase | `**negrito**` · `_itálico_` · `~~riscado~~` · `` `código` `` |
| link / imagem | `[texto](url)` · `![descrição](caminho.png)` |
| lista de tarefas | `- [ ] pendente` · `- [x] feita` |
| tabela | `\| A \| B \|` + `\|---\|:---:\|` (`:` alinha) |
| bloco de código | ` ```bash ` … ` ``` ` |
| sugestão em revisão | ` ```suggestion ` … ` ``` ` |
| diagrama | ` ```mermaid ` … ` ``` ` (também `geojson`, `topojson`, `stl`) |
| alerta | `> [!NOTE]` · `[!TIP]` · `[!IMPORTANT]` · `[!WARNING]` · `[!CAUTION]` |
| recolhível | `<details><summary>Ver log</summary>` … `</details>` |
| nota de rodapé | `texto[^1]` + `[^1]: nota` |
| matemática | `$x^2$` · `$$\sum_i x_i$$` |
| menção / referência | `@usuario` · `@org/time` · `#42` · `org/repo#42` · SHA |
| emoji | `:rocket:` → 🚀 |

## Atalhos de teclado (aperte `?` em qualquer página)

| Onde | Tecla | Ação |
|---|---|---|
| qualquer | `s` ou `/` | busca |
| qualquer | `g` `n` | notificações |
| repositório | `t` | localizar arquivo |
| repositório | `.` | abrir no github.dev (editor no navegador) |
| repositório | `g` `c` / `g` `i` / `g` `p` / `g` `a` | Code / Issues / PRs / Actions |
| arquivo | `y` | permalink (URL presa ao commit) |
| arquivo | `b` | blame |
| arquivo | `l` | ir para a linha |
| issue/PR | `c` | criar |
| PR | `Ctrl`+`Shift`+`P` | alternar edição/pré-visualização |

## Truques de URL

| URL | Mostra |
|---|---|
| `…/compare/main...feature` | diferença entre duas branches (e botão de PR) |
| `…/pull/7.diff` · `…/pull/7.patch` | o PR como diff / patch aplicável com `git am` |
| `…/commit/SHA?w=1` | diff ignorando espaços em branco |
| `…/blob/SHA/app.js#L10-L20` | trecho de linhas, permanente |
| `…/blame/main/app.js` | quem mudou cada linha |
| `…/issues?q=is:open+no:assignee` | busca salva como link |
| `…/new/main?filename=docs/x.md` | criar arquivo pelo navegador |
| `…/community` | checklist de saúde da comunidade |
| `…/security/policy` | o SECURITY.md do projeto |
| `github.com/USUARIO.keys` | chaves SSH públicas de alguém (útil para dar acesso a um servidor) |

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · CC BY-NC-SA 4.0</sub>
