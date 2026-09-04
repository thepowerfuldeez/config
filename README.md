# Mac setup

Personal Mac settings, refreshed from the current machine on 2026-09-04.
Ghostty is the default terminal. The Brewfile no longer includes iTerm, Artisan,
Aria2D or LM Studio; it does not uninstall existing applications.

## Restore on a new Mac

```bash
git clone https://github.com/thepowerfuldeez/config.git ~/config
~/config/install.sh
```

The installer uses its own checkout, installs the Brewfile and VS Code
extensions, and restores the shell, Neovim, Git ignores, Ghostty and VS Code
settings. It sets Ghostty as the macOS default terminal for the shell role.
If the old managed shell block contains custom edits, the installer stops before
changing files and asks you to move those edits to `~/.zshrc.local`.
Existing files are backed up under `~/.local/state/config-backups/` before
replacement. It preserves unmanaged shell configuration and Git identity.
It does not pull changes automatically; use `git pull --ff-only` when ready.

The Brewfile tracks explicitly installed CLI tools and the chosen applications.
VS Code extensions have a single install list, `vscode-extensions.txt`, combining
the current Default and `main` profiles. `Brewfile.work` contains the optional
private work tap: install it separately with `brew bundle --file Brewfile.work`.
Homebrew-managed global npm/uv tools are not part of the base restore.

For configuration only:

```bash
SKIP_BREW=1 SKIP_EXTENSIONS=1 ~/config/install.sh
```

Set `SKIP_DEFAULT_TERMINAL=1` to retain a different terminal association.

## VS Code

`settings.json` and `keybindings.json` reflect the current `main` profile:
Solarized Dark, JetBrains Mono 13, autosave on focus change, Vim keybindings,
and Ghostty for external terminal launches. The installer copies these into
the Default profile. For a named profile, use **Profiles: Import Profile** and
select `main.code-profile`, then select `main` in VS Code.

Machine-specific SSH hosts, Kubernetes binary paths and settings for other
editors were omitted. Reconfigure remote hosts locally as needed. The separate
`main.code-profile` contains the same settings, bindings and extension list.

## Raycast

Open **Settings → Advanced → Import**, then select `raycast/settings.rayconfig`.
`raycast/settings.json` is the readable source of the same import. It includes:

- Control-Space launcher, system appearance, medium text, hidden menu bar icon.
- Escape behavior, macOS navigation bindings and 90-second return to root.
- Command-Shift-V clipboard-history shortcut and disabled-command preferences.
- Kill Process, Coffee, Color Picker and Arc extension identities and commands.

The sanitized import has no usage/search history, clipboard contents, notes,
AI chats, quicklinks, account IDs, extension tokens or extension preference
values. Extensions may need local setup or sign-in. Personal data should be
transferred separately using a private, encrypted export.

To refresh, export **Settings** and **Extensions** in Raycast to a private folder,
then run:

```bash
python3 scripts/export-raycast.py '/path/to/Raycast export.rayconfig'
git diff -- raycast/settings.json
```

Even a Settings-only raw export contains activity history. The script uses an
allowlist and writes only the portable preferences above. Review its output
before publishing. Raw exports must stay outside this repository.

## Shell, Git and macOS

The managed shell configuration is sourced from `~/.config/shell/config.zsh`.
It includes eza/uv/nvim aliases, `tabify`, fzf, zoxide, shared deduplicated history,
autosuggestions and syntax highlighting. Keep credentials and machine-specific
paths in `~/.zshrc.local`, which is sourced but never tracked. The installer
removes the old iTerm shell-integration hook. Ghostty supplies its own integration.

Git ignore patterns are restored via `~/.config/git/config`. Set your identity
locally with `git config --global user.name` and `git config --global user.email`.
The optional `git/work.config` contains the existing work GitHub SSH rewrite;
include it locally if needed. Machine-specific `safe.directory` exceptions are
not copied.

Run `bash macos/preferences.sh` manually to restore the captured macOS choices:
dark appearance, key repeat 2 / initial delay 15, Finder list view, Dock icon
size 40 and tap-to-click off. Log out and back in for all changes to take effect.
These preferences are opt-in; the installer does not run this script.

## Validation

```bash
bash -n install.sh macos/preferences.sh
zsh -n zshrc.snippet
brew bundle list --file Brewfile
/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config --config-file="$PWD/ghostty/config"
```

Install the theme in `~/.config/ghostty/themes/` before standalone Ghostty
validation. The installer does this automatically. `init.vim` and the shell
startup profiler remain available from the previous setup.
