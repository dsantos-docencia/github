#!/usr/bin/env python3
# ============================================================================
#  Curso de GitHub · ferramentas/lib/yaml2json.py — YAML → JSON para os testes
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  PEGADINHA CLÁSSICA: no YAML 1.1 (o que o PyYAML implementa), a palavra `on`
#  sem aspas vira o booleano True. Então `on: push` de um workflow vira
#  {True: "push"}! O GitHub usa um parser próprio e entende `on` como texto,
#  mas muitas ferramentas não. Aqui convertemos chaves booleanas de volta
#  para "on"/"off" — e o Módulo 07 explica isso com calma.
# ============================================================================
import json
import sys

import yaml


def chaves_texto(o):
    if isinstance(o, dict):
        return {("on" if k is True else "off" if k is False else k): chaves_texto(v) for k, v in o.items()}
    if isinstance(o, list):
        return [chaves_texto(v) for v in o]
    return o


try:
    with open(sys.argv[1], encoding="utf-8") as f:
        dado = yaml.safe_load(f)
except (OSError, yaml.YAMLError) as erro:
    print(f"YAML inválido em {sys.argv[1]}: {erro}", file=sys.stderr)
    sys.exit(1)
json.dump(chaves_texto(dado), sys.stdout, ensure_ascii=False, default=str)
