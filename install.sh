#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:thepowerfuldeez/config.git"
REPO_DIR="${REPO_DIR:-$HOME/config}"

if [[ ! -d "$REPO_DIR/.git" ]]; then
  git clone --depth=1 "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" pull --rebase
fi

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  BREW_BIN="/opt/homebrew/bin/brew"
elif [[ -x /usr/local/bin/brew ]]; then
  BREW_BIN="/usr/local/bin/brew"
else
  BREW_BIN="$(command -v brew)"
fi

eval "$("$BREW_BIN" shellenv)"

"$BREW_BIN" bundle --file "$REPO_DIR/Brewfile"

touch "$HOME/.zprofile"
if ! grep -q "brew shellenv" "$HOME/.zprofile"; then
  echo "eval \"\$($BREW_BIN shellenv)\"" >> "$HOME/.zprofile"
fi

mkdir -p "$HOME/.local/bin"
LOCAL_ENV="$HOME/.local/bin/env"
if [[ ! -f "$LOCAL_ENV" ]]; then
  cat > "$LOCAL_ENV" <<'EOF'
#!/bin/sh
# add binaries to PATH if they aren't added yet
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed binary needs to be overridden
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac
EOF
  chmod +x "$LOCAL_ENV"
fi

touch "$HOME/.profile"
if ! grep -q '\. "$HOME/.local/bin/env"' "$HOME/.profile"; then
  echo '. "$HOME/.local/bin/env"' >> "$HOME/.profile"
fi

touch "$HOME/.zshrc"
if ! grep -q "^# >>> config repo >>>" "$HOME/.zshrc"; then
  cat "$REPO_DIR/zshrc.snippet" >> "$HOME/.zshrc"
fi

mkdir -p "$HOME/.config/nvim"
cp "$REPO_DIR/init.vim" "$HOME/.config/nvim/init.vim"

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER_DIR"
cp "$REPO_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
cp "$REPO_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"

if command -v code >/dev/null 2>&1; then
  xargs -n 1 code --install-extension < "$REPO_DIR/vscode-extensions.txt"
fi

cp "$REPO_DIR/bin/zsh-startup-profiler" "$HOME/.local/bin/zsh-startup-profiler"
chmod +x "$HOME/.local/bin/zsh-startup-profiler"
