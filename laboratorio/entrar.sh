#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub — laboratorio/entrar.sh
#  Abre um terminal dentro do container do curso, com o repositório montado.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
set -euo pipefail

RAIZ="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGEM="curso-github:lab"

if ! command -v docker >/dev/null; then
    cat >&2 <<'MSG'
Docker não encontrado. Instale a partir de https://docs.docker.com/get-docker/
Sem Docker, você usa o curso direto na sua máquina (Bash, Git, gh, jq e python3) — o container é só
uma conveniência para ter um ambiente idêntico e descartável.
MSG
    exit 1
fi

# Constrói a imagem na primeira vez (ou depois de: docker rmi curso-github:lab).
if ! docker image inspect "$IMAGEM" >/dev/null 2>&1; then
    echo "Construindo a imagem do laboratório (só na primeira vez)…"
    docker build -t "$IMAGEM" "$RAIZ/laboratorio"
fi

echo "Entrando no laboratório. O repositório está em /curso. Digite 'exit' para sair."
# --rm: descartado ao sair · -v: o repositório do curso montado em /curso
# Se você já fez "gh auth login" na sua máquina, o token pode ser repassado
# para rodar os exemplos com GH_REAL=1 dentro do container: GH_TOKEN=$(gh auth token) ./laboratorio/entrar.sh
exec docker run --rm -it -v "$RAIZ:/curso" ${GH_TOKEN:+-e GH_TOKEN} "$IMAGEM" bash
