# Obsidian: write freely, find things through tags

This is a configuration-only export of the current Mac setup, updated 2026-09-04.
The vault lives in Obsidian's iCloud Drive folder. Notes and attachments are kept
there; no vault content, recent-file lists, search history, private note titles,
plugin caches, accounts or credentials are published here.

## Everyday use

- **Cmd-N:** an ordinary empty note in `inbox`, ready for Live Preview editing.
- **Cmd-Shift-E:** a freeform experiment. Name is optional. Starts with a date and
  `#experiment`, then a blank space to write. No required category or sections.
- Add a few useful tags in the body, such as `#moe`, `#evals`, `#long-context`.
  They do not need to be properties or follow a fixed taxonomy.
- **Cmd-G:** graph; press again to return to your previous view and cursor.
  Tags and unlinked notes are visible. Inbox is included; templates, media,
  source documents and deprecated archives are filtered out.
- **Cmd-Shift-G:** local graph around the current note.
- Click the small toolbar for bold, italic, headings, lists, code, links,
  tables and callouts. Its buttons insert Markdown.
- Type **/** to search commands. Use the native table editor's Tab/Shift-Tab
  navigation and row/column controls when recording results.
- Tags appear beneath note previews in Notebook Navigator. Its **Untagged**
  entry helps find things to tag later; the calendar and properties sections
  are hidden to reduce clutter.
- For tag maintenance, run **Tags view: Show tags**, then right-click a tag to
  rename/merge or refine a search. No tags are renamed automatically.

The graph connects notes to shared tag nodes. It does not infer relationships
from your prose. A broad `#experiment` tag gives a useful hub; specific topic
tags create more informative clusters. There is no need to reorganize folders.

## Preserved features and additions

The export includes all seven previously enabled plugins: Dataview, Tasks,
Auto Link Title, Advanced URI, Minimal Theme Settings, Notebook Navigator and
the custom Laguna Workflow plugin. Their settings, hotkeys, core-plugin choices,
Minimal theme, custom CSS and reusable templates are preserved.

Two plugins were added from Obsidian's community directory:

- [Editing Toolbar](https://github.com/PKM-er/obsidian-editing-toolbar), configured
  as nine Markdown formatting buttons. Its AI features are disabled.
- [Tag Wrangler](https://github.com/pjeby/tag-wrangler), for tag maintenance.

The custom workflow retains **New structured experiment (optional)** in the
command palette and the Experiment/Weekly Update templates. Template exports
omit navigation links to private vault notes; existing templates are never
replaced during restore. Automatic date insertion into arbitrary new/imported
notes was removed; only explicit experiment creation adds a date.

## Restore

Open the existing iCloud vault on the new Mac, then quit Obsidian:

```bash
python3 obsidian/restore.py '/path/to/your/vault' --dry-run
python3 obsidian/restore.py '/path/to/your/vault'
```

The script downloads exact, pinned release artifacts from the official plugin
repositories and verifies SHA-256 checksums before changing files. It preserves
a harmless existing Advanced URI build suffix. The custom plugin and theme are
stored here directly. Obsidian 1.13.7 was used for validation; Notebook Navigator
requires at least 1.11.0.

Replaced configuration files are backed up privately under
`~/.local/state/obsidian-config-backups/`. Existing notes, attachments, templates
and workspace tabs stay intact. A new vault gets a content-free sidebar layout.
If community plugins are disabled in the destination vault, enable them in
Obsidian's Community plugins settings.

`config/` contains the portable settings; `plugins.lock.json` records the eight
upstream plugins. `config/plugins/laguna-workflow/` contains the custom ninth
plugin. No Obsidian account or iCloud registration is exported.

## Validation

```bash
node --check obsidian/config/plugins/laguna-workflow/main.js
node obsidian/test-workflow.cjs
python3 obsidian/restore.py '/path/to/your/vault' --dry-run
```

Live UI checks covered freeform creation, Markdown bold, native table insertion,
Cmd-G round trip, enabled graph filters and Tag Wrangler's context menu. All 320
pre-existing vault files were verified byte-for-byte unchanged after testing.

References: [Graph filters](https://obsidian.md/help/plugins/graph),
[Live Preview](https://obsidian.md/help/edit-and-read),
[Slash commands](https://obsidian.md/help/plugins/slash-commands).
