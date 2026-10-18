#!/usr/bin/env bash
# dump-project.sh — собирает исходники проекта в один текстовый отчёт
# Использование: ./dump-project.sh [имя_выходного_файла]
# По умолчанию: project-dump.txt

set -euo pipefail

OUT="${1:-project-dump.txt}"
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Что исключаем из обхода
EXCLUDES=(
  "_site"
  ".git"
  ".devcontainer"
  "node_modules"
  "vendor"
  ".jekyll-cache"
  ".sass-cache"
  "Gemfile.lock"
  "project-dump.txt"
  "dump-project.sh"
  "mermaid.min.js"
  "tuicss.min.css"
)

# Собираем find-выражение для исключений
FIND_EXCLUDE=()
for e in "${EXCLUDES[@]}"; do
  FIND_EXCLUDE+=( -name "$e" -prune -o )
done

# Расширения, которые считаем бинарными (только имя + размер, без содержимого)
BINARY_EXT=(
  "woff" "woff2" "ttf" "otf" "eot"
  "png" "jpg" "jpeg" "gif" "svg" "ico" "webp"
  "pdf" "zip" "gz" "tar"
  "mp4" "webm" "mp3"
)

is_binary() {
  local f="$1"
  local ext="${f##*.}"
  ext="${ext,,}"
  for b in "${BINARY_EXT[@]}"; do
    [[ "$ext" == "$b" ]] && return 0
  done
  return 1
}

{
  echo "======================================================================"
  echo "PROJECT DUMP: $(basename "$ROOT")"
  echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "======================================================================"
  echo

  # 1. Дерево (без исключённых)
  echo "----------------------------------------------------------------------"
  echo "TREE (excluding: ${EXCLUDES[*]})"
  echo "----------------------------------------------------------------------"
  if command -v tree >/dev/null 2>&1; then
    TREE_EXCLUDES=()
    for e in "${EXCLUDES[@]}"; do
      TREE_EXCLUDES+=( -I "$e" )
    done
    tree -a -I "$(IFS='|'; echo "${EXCLUDES[*]}")" "$ROOT" 2>/dev/null || \
      find "$ROOT" "${FIND_EXCLUDE[@]}" -type f -print | sed "s|$ROOT/||" | sort
  else
    find "$ROOT" "${FIND_EXCLUDE[@]}" -type f -print | sed "s|$ROOT/||" | sort
  fi
  echo

  # 2. Содержимое текстовых файлов
  echo "----------------------------------------------------------------------"
  echo "FILE CONTENTS"
  echo "----------------------------------------------------------------------"
  while IFS= read -r -d '' f; do
    rel="${f#$ROOT/}"
    echo
    echo "======================================================================"
    echo "FILE: $rel"
    echo "======================================================================"
    if is_binary "$f"; then
      size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null || echo "?")
      echo "[binary file, ${size} bytes — content skipped]"
    else
      echo '```'
      cat "$f"
      echo '```'
    fi
  done < <(find "$ROOT" "${FIND_EXCLUDE[@]}" -type f -print0 | sort -z)

  echo
  echo "======================================================================"
  echo "END OF DUMP"
  echo "======================================================================"
} > "$OUT"

echo "Готово: $OUT"
echo "Размер: $(wc -c < "$OUT") байт"

