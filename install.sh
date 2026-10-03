#!/usr/bin/env bash
# Ставит скилы информационного стиля как личные скилы агентов через симлинки.
#   bash install.sh            — Claude Code (~/.claude/skills) и общий каталог агентов (~/.agents/skills)
#   bash install.sh --uninstall — удалить симлинки
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
targets=("$HOME/.claude/skills" "$HOME/.agents/skills")
skills=(infostyle infostyle-review infostyle-selling infostyle-cover-letter)

for target in "${targets[@]}"; do
  mkdir -p "$target"
  for skill in "${skills[@]}"; do
    link="$target/$skill"
    if [[ "${1:-}" == "--uninstall" ]]; then
      [[ -L "$link" ]] && rm "$link" && echo "удалён $link"
      continue
    fi
    if [[ -e "$link" && ! -L "$link" ]]; then
      echo "пропущен $link: уже существует и это не симлинк" >&2
      continue
    fi
    ln -sfn "$repo_dir/skills/$skill" "$link"
    echo "$link -> $repo_dir/skills/$skill"
  done
done
