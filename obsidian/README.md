# Obsidian

Settings, plugins, theme and templates. Notes and attachments stay in iCloud Drive.

## Writing

- **Cmd-N:** empty note in `inbox`, using Live Preview.
- **Cmd-Shift-E:** freeform experiment with a date and `#experiment` tag.
- **Cmd-G:** graph; press again to return to the previous view and cursor.
- **Cmd-Shift-G:** local graph.
- Use the formatting toolbar for Markdown, or type **/** to search commands.
- Add topic tags such as `#moe`, `#evals` or `#long-context` anywhere in the body.
- Open **Tags view: Show tags** and right-click a tag to rename or merge it.

The graph shows tags and unlinked notes, including the inbox. Templates, media,
source documents and archives are filtered out. Notebook Navigator shows tags
under note previews and has an **Untagged** entry.

For structured writing, use **New structured experiment (optional)** in the
command palette or the Experiment and Weekly Update templates.

## Plugins

Dataview, Tasks, Auto Link Title, Advanced URI, Minimal Theme Settings,
Notebook Navigator, Editing Toolbar, Tag Wrangler and the custom Laguna Workflow.
The export also includes the Minimal theme, CSS, hotkeys and core-plugin settings.

## Restore

Open the iCloud vault on the new Mac, then quit Obsidian:

```bash
python3 obsidian/restore.py '/path/to/your/vault' --dry-run
python3 obsidian/restore.py '/path/to/your/vault'
```

The script downloads pinned plugin releases and verifies SHA-256 checksums.
Replaced settings are backed up under `~/.local/state/obsidian-config-backups/`.
Existing notes, attachments, templates and workspace tabs are preserved.
Enable community plugins in Obsidian if needed. Notebook Navigator requires
Obsidian 1.11.0 or later.

`config/` holds settings, the theme and the custom plugin. `plugins.lock.json`
records upstream plugin versions and checksums. Accounts, credentials, caches
and recent-file history are excluded.

## Check

```bash
node --check obsidian/config/plugins/laguna-workflow/main.js
node obsidian/test-workflow.cjs
python3 obsidian/restore.py '/path/to/your/vault' --dry-run
```
