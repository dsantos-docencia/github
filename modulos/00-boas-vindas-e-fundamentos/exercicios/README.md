# 🏋️ Exercícios — Módulo 00

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 00        # todos do módulo
./ferramentas/corrigir.sh 00 01     # só o exercício 01
```

Os exercícios deste módulo treinam Markdown do GitHub, o repositório especial de perfil e a configuração do `gh`.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — README com recursos do GitHub · `01-readme-gfm.sh`
Faça o script criar, na pasta atual, um `README.md` que use os recursos do GitHub Flavored Markdown:
1. um título de nível 1 (`# ...`);
2. um **alerta** do tipo `NOTE` (`> [!NOTE]` seguido de uma linha de texto `> ...`);
3. uma **lista de tarefas** com pelo menos **dois** itens, sendo pelo menos um marcado (`- [x]`) e um pendente (`- [ ]`);
4. uma **tabela** com cabeçalho e linha separadora (`|---|`);
5. um bloco de diagrama **mermaid** (abre com ` ```mermaid ` e fecha com ` ``` `).

Dica: use um *here-document* com aspas (`cat > README.md <<'MD' … MD`) para o Bash não interpretar crases e `$`.

### 02 — O repositório especial de perfil · `02-readme-de-perfil.sh`
No GitHub, um repositório com **o mesmo nome do seu usuário** (`voce/voce`) é especial: o README dele aparece no topo do seu perfil.

O script recebe o nome de usuário como `$1` e deve:
1. sair com código **2** e uma mensagem de uso em stderr se `$1` não for informado;
2. criar a pasta `$1` como repositório Git (branch `main`);
3. criar nela um `README.md` cuja primeira linha seja `### Olá, eu sou @USUARIO 👋` (com o usuário recebido);
4. fazer um commit com a mensagem exata `docs: README do perfil`.

Para publicar de verdade (fora do exercício): `gh repo create USUARIO --public --source USUARIO --push`.

### 03 — Deixando o gh do seu jeito · `03-configurar-gh.sh`
Configure o **gh de verdade** (sem internet: configuração e alias são locais). O corretor usa uma pasta de configuração temporária, então a sua não é tocada.

1. `git_protocol` = `ssh`;
2. `prompt` = `disabled` (o gh nunca para esperando resposta — essencial em scripts);
3. um alias `minhas` que execute `issue list --assignee @me`;
4. um alias `rascunho` que execute `pr create --draft --fill`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
