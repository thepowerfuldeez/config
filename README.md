## Install
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle

echo '
alias ls=eza
alias pip="uv pip"
alias python=python3
alias vim=nvim
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/george/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
' >> ~/.zshrc

git clone --depth=1 https://github.com/thepowerfuldeez/config.git config/
bash config/install.sh
```
