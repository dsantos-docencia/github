# 🏋️ Exercícios — Módulo 09

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 09        # todos do módulo
./ferramentas/corrigir.sh 09 01     # só o exercício 01
```

Os exercícios treinam a configuração das notas de release, uma publicação completa com checksums e o workflow do Pages.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Categorias das notas de release · `01-release-yml.sh`
Crie `.github/release.yml` com:
- `changelog.exclude.labels`: `[ignorar-nas-notas]` e `changelog.exclude.authors`: `[dependabot]`;
- `changelog.categories`, **nesta ordem**:
  1. `title: 🚀 Novidades` com `labels: [feature, melhoria]`;
  2. `title: 🐛 Correções` com `labels: [bug]`;
  3. `title: Outras mudanças` com `labels: ["*"]` — a categoria “coringa” precisa ser a **última**.

### 02 — Publicar uma release com checksums · `02-publicar-release.sh`
O script recebe a versão (`v1.2.0`, `v2.0.0-rc.1`…) e a pasta `src/` já existe. Ele deve:

1. validar o formato `vX.Y.Z` com sufixo opcional `-algo` (inválido → stderr e saída **2**, sem chamar o `gh`);
2. criar `dist/loja-X.Y.Z.tar.gz` (sem o `v`) com o conteúdo de `src/`;
3. criar `dist/SHA256SUMS` no formato do `sha256sum`, **com caminhos relativos à pasta `dist`** (ex.: `abc…  loja-1.2.0.tar.gz`), para que `cd dist && sha256sum -c SHA256SUMS` funcione;
4. chamar `gh release create vX.Y.Z dist/loja-X.Y.Z.tar.gz dist/SHA256SUMS --title vX.Y.Z --generate-notes --verify-tag`, acrescentando `--prerelease` quando a versão tiver `-`.

### 03 — Workflow de publicação no Pages · `03-workflow-pages.sh`
Crie `.github/workflows/pages.yml`:
- dispara em push na `main` e em `workflow_dispatch`;
- `permissions` no topo: `contents: read`, `pages: write`, `id-token: write`;
- `concurrency` com `group: pages` e `cancel-in-progress: false`;
- job `build`: checkout, `actions/configure-pages` e `actions/upload-pages-artifact` com `path: _site` — **todas** as ações fixadas por SHA;
- job `deploy`: `needs: build`, `environment.name: github-pages`, `environment.url: ${{ steps.deploy.outputs.page_url }}` e um step com `id: deploy` usando `actions/deploy-pages` (fixado por SHA).

SHAs atuais (pode copiar): `actions/configure-pages@45bfe0192ca1faeb007ade9deae92b16b8254a0d # v6.0.0` · `actions/upload-pages-artifact@fc324d3547104276b827a68afc52ff2a11cc49c9 # v5.0.0` · `actions/deploy-pages@368f82528645a54fb793d4d04e342629a3f51346 # v5.0.1`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
