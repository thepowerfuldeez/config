#!/usr/bin/env python3
"""Restore configuration and verified plugin releases, never vault content."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent


def digest(data):
    return hashlib.sha256(data).hexdigest()


def prepare(stage):
    shutil.copytree(ROOT / "config", stage, dirs_exist_ok=True)
    for plugin in json.loads((ROOT / "plugins.lock.json").read_text()):
        dest = stage / "plugins" / plugin["id"]
        dest.mkdir(parents=True, exist_ok=True)
        for asset in plugin["files"]:
            url = asset["url"]
            if not url.lower().startswith(f'https://github.com/{plugin["repo"]}/releases/download/'.lower()):
                raise ValueError("Unexpected plugin source URL")
            with urlopen(Request(url, headers={"User-Agent": "obsidian-config-restore"}), timeout=60) as response:
                data = response.read()
            if digest(data) != asset["sha256"]:
                raise ValueError(f'Checksum mismatch: {plugin["id"]}/{asset["name"]}')
            data += asset.get("append", "").encode()
            if "installedSha256" in asset and digest(data) != asset["installedSha256"]:
                raise ValueError("Patched artifact checksum mismatch")
            (dest / asset["name"]).write_bytes(data)
        manifest = json.loads((dest / "manifest.json").read_text())
        if manifest["id"] != plugin["id"] or manifest["version"] != plugin["version"].removeprefix("v"):
            raise ValueError(f'Plugin manifest mismatch: {plugin["id"]}')
    enabled = json.loads((stage / "community-plugins.json").read_text())
    for plugin_id in enabled:
        for name in ("manifest.json", "main.js"):
            if not (stage / "plugins" / plugin_id / name).is_file():
                raise ValueError(f"Missing enabled plugin file: {plugin_id}/{name}")
    for path in stage.rglob("*.json"):
        json.loads(path.read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("vault", type=Path, help="Existing vault folder (not .obsidian)")
    parser.add_argument("--dry-run", action="store_true", help="Download and verify all files without changing the vault")
    args = parser.parse_args()
    vault = args.vault.expanduser().resolve()
    if not vault.is_dir() or vault.name == ".obsidian":
        parser.error("Pass an existing vault folder, not its .obsidian folder")
    if not args.dry_run and sys.platform == "darwin":
        if subprocess.run(["pgrep", "-x", "Obsidian"], stdout=subprocess.DEVNULL).returncode == 0:
            parser.error("Quit Obsidian before restoring so it cannot overwrite restored settings")
    with tempfile.TemporaryDirectory(prefix="obsidian-restore-") as temp:
        stage = Path(temp) / "config"
        prepare(stage)  # Complete all network verification before changing anything.
        files = sorted(p for p in stage.rglob("*") if p.is_file())
        if args.dry_run:
            print(f"Verified {len(files)} configuration/plugin files. No vault changes.")
            return
        backup = Path.home() / ".local/state/obsidian-config-backups" / datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        backup.mkdir(parents=True, mode=0o700)
        os.chmod(backup, 0o700)
        for source in files:
            relative = source.relative_to(stage)
            target = vault / ".obsidian" / relative
            if target.is_symlink() or any(parent.is_symlink() for parent in target.parents if parent != vault):
                raise ValueError(f"Refusing to write through symlink: {target}")
            if target.exists():
                saved = backup / relative
                saved.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(target, saved)
            target.parent.mkdir(parents=True, exist_ok=True)
            temporary = target.with_name(target.name + ".restore-tmp")
            shutil.copy2(source, temporary)
            temporary.replace(target)
        # A content-free layout is only needed on a fresh vault.
        workspace = vault / ".obsidian/workspace.json"
        if not workspace.exists():
            shutil.copy2(ROOT / "workspace-template.json", workspace)
        # Reusable templates are only created when absent; never replace notes.
        for source in (ROOT / "templates").glob("*.md"):
            target = vault / "Templates" / source.name
            if not target.exists():
                target.parent.mkdir(parents=True, exist_ok=True)
                with target.open("x") as output:
                    output.write(source.read_text())
        print(f"Restored settings and plugins. Backups: {backup}")
        print("Open this vault in Obsidian. Existing notes, attachments and workspace tabs were preserved.")


if __name__ == "__main__":
    main()
