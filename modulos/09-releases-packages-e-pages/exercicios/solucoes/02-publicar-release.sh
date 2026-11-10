#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 09.02 — Publicar uma release com checksums · SOLUÇÃO COMENTADA
set -euo pipefail

tag="${1:-}"
if ! [[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?)$ ]]; then
    echo "uso: $0 vX.Y.Z[-pre]" >&2
    exit 2
fi
versao="${BASH_REMATCH[1]}"            # o grupo 1 do regex: a versão sem o "v"
pacote="loja-$versao.tar.gz"

mkdir -p dist
tar -czf "dist/$pacote" src
# Entramos em dist/ para o checksum registrar o NOME do arquivo, não o caminho.
(cd dist && sha256sum "$pacote" > SHA256SUMS)

extra=()
[[ "$versao" == *-* ]] && extra+=(--prerelease)
gh release create "$tag" "dist/$pacote" dist/SHA256SUMS \
    --title "$tag" --generate-notes --verify-tag "${extra[@]}"
