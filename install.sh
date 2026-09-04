#!/usr/bin/env bash
set -euo pipefail

# Run from this checkout. Do not pull or replace a dirty checkout implicitly.
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.local/state/config-backups/$(date +%Y%m%d-%H%M%S)-$$}"
SKIP_BREW="${SKIP_BREW:-0}"
SKIP_EXTENSIONS="${SKIP_EXTENSIONS:-0}"
SKIP_DEFAULT_TERMINAL="${SKIP_DEFAULT_TERMINAL:-0}"

# Refuse to discard custom edits inside the previous managed block.
python3 - "$HOME/.zshrc" "$REPO_DIR/scripts/legacy-zshrc.snippet" <<'PY_CHECK'
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
s = p.read_text() if p.exists() else ""
m = re.search(r'(?ms)^# >>> config repo >>>\n.*?^# <<< config repo <<<\n?', s)
if m and m.group().strip() != Path(sys.argv[2]).read_text().strip():
    sys.exit("Custom edits found in the old managed shell block. Move that block's custom settings to ~/.zshrc.local before restoring; no files were changed.")
PY_CHECK

backup() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${target#"$HOME"/}")"
    chmod 700 "$BACKUP_DIR"
    cp -pP "$target" "$BACKUP_DIR/${target#"$HOME"/}"
  fi
}
copy_config() {
  local source="$1" target="$2"
  if [[ -f "$target" ]] && cmp -s "$source" "$target"; then return; fi
  backup "$target"
  mkdir -p "$(dirname "$target")"
  # Replace symlinks without writing through into unrelated checkouts.
  rm -f "$target"
  cp "$source" "$target"
}

if [[ "$SKIP_BREW" != 1 ]]; then
  if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew && ! -x /usr/local/bin/brew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_BIN=/opt/homebrew/bin/brew
  else
    BREW_BIN="$(command -v brew || echo /usr/local/bin/brew)"
  fi
  eval "$("$BREW_BIN" shellenv)"
  "$BREW_BIN" bundle --file "$REPO_DIR/Brewfile"
  if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
    backup "$HOME/.zprofile"
    printf '\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$HOME/.zprofile"
  fi
fi

mkdir -p "$HOME/.local/bin" "$HOME/.config/shell"
copy_config "$REPO_DIR/zshrc.snippet" "$HOME/.config/shell/config.zsh"
# Replace only the old managed block and legacy iTerm integration line.
# Everything else, including existing local credentials, stays on this Mac.
backup "$HOME/.zshrc"
python3 - "$HOME/.zshrc" <<'PY'
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
s = p.read_text() if p.exists() else ""
s = re.sub(r'(?ms)^# >>> config repo >>>\n.*?^# <<< config repo <<<\n?', '', s)
s = '\n'.join(line for line in s.splitlines() if not ('.iterm2_shell_integration.zsh' in line and ('source ' in line or '&& .' in line)))
hook = '[ ! -r "$HOME/.config/shell/config.zsh" ] || source "$HOME/.config/shell/config.zsh"'
if hook not in s:
    s = hook + '\n' + s.lstrip('\n')
p.write_text(s.rstrip() + '\n')
PY
copy_config "$REPO_DIR/init.vim" "$HOME/.config/nvim/init.vim"
copy_config "$REPO_DIR/ghostty/config" "$HOME/.config/ghostty/config"
copy_config "$REPO_DIR/ghostty/themes/Personal Solarized" "$HOME/.config/ghostty/themes/Personal Solarized"
copy_config "$REPO_DIR/git/ignore" "$HOME/.config/git/ignore"
copy_config "$REPO_DIR/git/config" "$HOME/.config/git/config"
# Git auto-loads ~/.config/git/config alongside ~/.gitconfig. Identity, work
# URL rewrites and other local settings are intentionally preserved.

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
copy_config "$REPO_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
copy_config "$REPO_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
CODE_BIN="$(command -v code || true)"
if [[ -z "$CODE_BIN" && -x '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' ]]; then
  CODE_BIN='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
fi
if [[ "$SKIP_EXTENSIONS" != 1 && -n "$CODE_BIN" ]]; then
  while IFS= read -r extension; do
    [[ -z "$extension" ]] || "$CODE_BIN" --install-extension "$extension"
  done < "$REPO_DIR/vscode-extensions.txt"
fi
copy_config "$REPO_DIR/bin/zsh-startup-profiler" "$HOME/.local/bin/zsh-startup-profiler"
chmod +x "$HOME/.local/bin/zsh-startup-profiler"
if [[ "$SKIP_DEFAULT_TERMINAL" != 1 && -d /Applications/Ghostty.app ]]; then
  swift "$REPO_DIR/macos/default-terminal.swift"
fi
printf '\nSettings restored. Backups: %s\n' "$BACKUP_DIR"
printf 'Manual imports: main.code-profile (VS Code), raycast/settings.rayconfig (Raycast).\n'
printf 'Optional macOS preferences: bash "%s/macos/preferences.sh"\n' "$REPO_DIR"
