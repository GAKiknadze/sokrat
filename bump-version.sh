#!/usr/bin/env bash
# Поднимает версию плагина во всех манифестах. Без новой версии агенты не увидят обновление.
#   bash bump-version.sh patch   — 1.0.0 → 1.0.1 (правки текста скилов)
#   bash bump-version.sh minor   — 1.0.0 → 1.1.0 (новый скил или справочник)
#   bash bump-version.sh major   — 1.0.0 → 2.0.0 (переименование, удаление скилов)
#   bash bump-version.sh 1.2.3   — задать версию явно
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
files=(
  .claude-plugin/plugin.json
  .claude-plugin/marketplace.json
  .codex-plugin/plugin.json
  gemini-extension.json
)
version_re='"version": "[0-9]+\.[0-9]+\.[0-9]+"'

cd "$repo_dir"

current=""
for f in "${files[@]}"; do
  found="$(grep -Eo "$version_re" "$f" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' || true)"
  if [[ "$(wc -l <<<"$found")" -ne 1 || -z "$found" ]]; then
    echo "в $f должно быть ровно одно поле version" >&2
    exit 1
  fi
  if [[ -n "$current" && "$found" != "$current" ]]; then
    echo "версии расходятся: $current и $found в $f" >&2
    exit 1
  fi
  current="$found"
done

IFS=. read -r major minor patch <<<"$current"
case "${1:-}" in
  patch) next="$major.$minor.$((patch + 1))" ;;
  minor) next="$major.$((minor + 1)).0" ;;
  major) next="$((major + 1)).0.0" ;;
  [0-9]*.[0-9]*.[0-9]*)
    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "версия должна быть вида 1.2.3" >&2; exit 1; }
    next="$1" ;;
  *)
    echo "использование: bash bump-version.sh patch|minor|major|X.Y.Z (сейчас $current)" >&2
    exit 1 ;;
esac

for f in "${files[@]}"; do
  sed -E -i.bak "s/$version_re/\"version\": \"$next\"/" "$f" && rm "$f.bak"
done
echo "$current → $next"
