#!/usr/bin/env python3
"""Produce a reviewed, preferences-only Raycast import from a local export.

Usage: scripts/export-raycast.py /path/to/export.rayconfig
Never commit the original export: even Settings-only exports contain history.
"""
import gzip
import json
import sys
from pathlib import Path

repo = Path(__file__).resolve().parents[1]
source = json.loads(gzip.decompress(Path(sys.argv[1]).read_bytes()))
# Intentionally allowlisted fields. Unknown fields, tokens, activity, account
# identifiers, quicklinks, clipboard, notes and AI conversations are omitted.
result = {"raycast_version": source["raycast_version"]}
prefs = source["builtin_package_raycastPreferences"]
allowed = {
    "preferencesGeneral": {"raycastGlobalHotkey", "raycastAlternativeEscape"},
    "preferencesAppearance": {"raycastShouldFollowSystemAppearance", "raycastPreferredWindowMode", "showFavoritesInCompactMode", "statusBarIsVisible", "raycastUI_preferredTextSize"},
    "preferencesAdvanced": {"mainWindowCaptureCopyToClipboard", "mainWindowCaptureOpenQuickAccessOverlay", "keepWindowVisibleOnResignKey", "navigationCommandStyleIdentifierKey", "raycastWindowEscapeKeyBehavior", "mainWindowCaptureShowInFinder", "useHyperKeyIcon", "popToRootTimeout", "pageNavigationCommandKeysIdentifierKey", "raycastWindowPresentationMode"},
}
result["builtin_package_raycastPreferences"] = {
    "provider_schemaVersion": prefs["provider_schemaVersion"],
    **{group: {k: v for k, v in prefs.get(group, {}).items() if k in keys} for group, keys in allowed.items()},
}
for name, package in source.items():
    if isinstance(package, dict) and "disabledCommands" in package:
        result[name] = {"provider_schemaVersion": package["provider_schemaVersion"], "disabledCommands": package["disabledCommands"]}
# Only explicit shortcuts and favorites; never recency, search queries or paths.
root = source.get("builtin_package_rootSearch", {})
shortcuts = []
for item in root.get("rootSearch", []):
    if item.get("type") == "command" and any(k in item for k in ("hotkey", "alias", "isFavorite")):
        shortcuts.append({k: v for k, v in item.items() if k in {"type", "key", "hotkey", "alias", "isFavorite"}})
if shortcuts:
    result["builtin_package_rootSearch"] = {"provider_schemaVersion": root["provider_schemaVersion"], "rootSearch": shortcuts}
# Keep store extension identities and enabled command states, no preference
# values or tokenSets. Extensions may request fresh sign-in after import.
extensions = source.get("builtin_package_raycastExtensions", {})
safe_extensions = []
for ext in extensions.get("extensions", []):
    safe_extensions.append({
        **{k: ext[k] for k in ("name", "title", "owner", "access")},
        "commands": [{k: c[k] for k in ("name", "enabled") if k in c} for c in ext.get("commands", [])],
        "prefs": [], "tokenSets": [],
    })
result["builtin_package_raycastExtensions"] = {"provider_schemaVersion": extensions["provider_schemaVersion"], "extensions": safe_extensions, "localExtensions": []}
out = repo / "raycast"
out.mkdir(exist_ok=True)
text = json.dumps(result, indent=2, sort_keys=True) + "\n"
(out / "settings.json").write_text(text)
(out / "settings.rayconfig").write_bytes(gzip.compress(text.encode(), mtime=0))
print(f"Wrote preferences, {len(shortcuts)} shortcuts and {len(safe_extensions)} extensions; review raycast/settings.json before committing.")
