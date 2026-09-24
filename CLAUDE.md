# CLAUDE.md

## Contexto

Este directorio (`~/.local/bin`) contiene scripts personales. Aquí se va a crear
un repositorio git nuevo para un script que limpia sesiones antiguas de `~/.claude`.

## Objetivo de aprendizaje

El usuario quiere **escribir el script él mismo** para aprender Bash.

- NO escribas el script completo por él.
- Explica conceptos, responde dudas, revisa su código y sugiere mejoras.
- Si pide un ejemplo, muestra fragmentos pequeños y explica cada línea.
- Solo escribe código completo si lo pide explícitamente.

## Restricciones del repositorio git

- `waybar-restart.sh` **NUNCA** debe añadirse al repositorio. Es un symlink a
  `~/.dotfiles/scripts/.local/bin/waybar-restart.sh` y ya está versionado allí.
- El `.gitignore` usa el modo "lista blanca": ignora todo (`*`) y solo permite
  los archivos del proyecto de forma explícita (`!archivo`). Cualquier archivo
  nuevo que deba subirse hay que añadirlo al `.gitignore` con `!`.
- No uses `git add -f` ni `git add --force` (se saltaría el `.gitignore`).
- Antes de cada commit, revisa `git status` para confirmar que solo aparecen
  los archivos del proyecto.
- No hagas commit ni push sin que el usuario lo pida.

## Seguridad del script

- El script borra datos de `~/.claude`: nunca borrar sin confirmación del usuario
  ni fuera de `~/.claude/projects/`.
- Recomendar un modo `--dry-run` que muestre qué se borraría sin borrar nada.
