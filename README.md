# Mac setup

Ghostty, VS Code, Raycast, Obsidian, shell, Git and macOS settings.

## Install

```bash
git clone https://github.com/thepowerfuldeez/config.git ~/config
~/config/install.sh
```

Installs Homebrew packages and VS Code extensions, restores settings, and sets
Ghostty as the default terminal. Replaced files are backed up under
`~/.local/state/config-backups/`. Git identity and unmanaged shell settings stay
local. Custom edits in an older managed shell block must be moved to
`~/.zshrc.local` before restoring.

To restore settings without installing packages or extensions:

```bash
SKIP_BREW=1 SKIP_EXTENSIONS=1 ~/config/install.sh
```

Set `SKIP_DEFAULT_TERMINAL=1` to keep the current terminal association.
Update this checkout with `git pull --ff-only`.

## Homebrew

`Brewfile` includes Arc and the `domt4/autoupdate` tap. The installer trusts only
the tap's `autoupdate` command. To enable daily updates on a new Mac:

```bash
brew autoupdate start 1d --upgrade --cleanup
brew autoupdate status
```

Optional work tools:

```bash
brew bundle --file Brewfile.work
```

## VS Code

The installer copies `settings.json` and `keybindings.json` into the Default
profile and installs `vscode-extensions.txt`. To use the named profile, open
**Profiles: Import Profile** and select `main.code-profile`.

Settings include Solarized Dark, JetBrains Mono, Vim keybindings, autosave on
focus change and Ghostty for external terminals. Configure remote hosts locally.

## Raycast

Open **Settings → Advanced → Import** and select `raycast/settings.rayconfig`.
`raycast/settings.json` is its readable source. Extension accounts and
preferences need local setup.

To refresh, export Settings and Extensions to a private folder, then run:

```bash
python3 scripts/export-raycast.py '/path/to/Raycast export.rayconfig'
git diff -- raycast/settings.json
```

The script exports portable preferences and extension commands. Raw Raycast
exports contain private data; keep them outside this repository.

## Shell, Git and macOS

Shell settings live in `~/.config/shell/config.zsh`: eza, uv, fzf, zoxide,
autosuggestions, syntax highlighting, shared history and `tabify`.
Keep credentials and machine-specific settings in `~/.zshrc.local`.

Git ignores are loaded through `~/.config/git/config`. Set your Git identity
locally. Include `git/work.config` separately if you need the work SSH rewrite.

Run `bash macos/preferences.sh` to apply dark appearance, keyboard repeat,
Finder list view, Dock size and trackpad preferences. Log out and back in for
all changes to take effect.

## Obsidian

[Settings and shortcuts](obsidian/README.md). Notes and attachments stay in
iCloud Drive. Quit Obsidian before restoring into an existing vault:

```bash
python3 obsidian/restore.py '/path/to/your/vault'
```

## Check

```bash
bash -n install.sh macos/preferences.sh
zsh -n zshrc.snippet
brew bundle list --file Brewfile
```
