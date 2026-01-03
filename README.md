## Install
Quick install (SSH):
```bash
git clone --depth=1 git@github.com:thepowerfuldeez/config.git ~/config
~/config/install.sh
```

Or run the minimal install script directly:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thepowerfuldeez/config/main/install.sh)"
```

What it does:
- Installs Homebrew if missing
- Runs `brew bundle` for formulas/casks/VS Code extensions
- Appends `zshrc.snippet` if not already present
- Ensures `~/.local/bin/env` + PATH hooks
- Copies Neovim + VS Code settings
- Installs `zsh-startup-profiler` into `~/.local/bin`

Manual imports:
- iTerm2: import `iTerm2 State.itermexport`
- VS Code profile: import `default.code-profile` (optional)

VS Code extensions (manual alternative):
```bash
xargs -n 1 code --install-extension < vscode-extensions.txt
```
