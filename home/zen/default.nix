{ lib, pkgs, ... }:
let
  # Web apps that must not swallow browser shortcuts (Alt+1-9 -> tab,
  # Ctrl+Alt+1-9 -> workspace, ...).
  #
  # Firefox has a per-site permission for exactly this: "Override keyboard
  # shortcuts" (Ctrl+I -> Permissions). With it set to Block, every browser
  # shortcut is handled by Zen and never reaches the page's preventDefault().
  #
  # This replaces the old trick of setting reserved=true in
  # zen-keyboard-shortcuts.json: since Zen 1.24b shortcuts live in Firefox's
  # about:keyboard store (customKeys.json), which has no reserved flag, and the
  # old file is not read anymore.
  blockedOrigins = [
    "https://outlook.office.com"
    "https://outlook.office365.com"
    "https://outlook.cloud.microsoft"
    "https://teams.microsoft.com"
    "https://teams.cloud.microsoft"
    "https://teams.live.com"
  ];

  # moz_perms: permission 2 = DENY, expireType 0 = never
  sql = ''
    BEGIN;
    ${lib.concatMapStrings (o: ''
      DELETE FROM moz_perms WHERE origin = '${o}' AND type = 'shortcuts';
      INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime)
        VALUES ('${o}', 'shortcuts', 2, 0, 0, CAST(strftime('%s','now') AS INTEGER) * 1000);
    '') blockedOrigins}
    COMMIT;
  '';

  blockShortcutOverrides = pkgs.writeShellScript "zen-block-shortcut-overrides" ''
    set -u
    sqlite=${lib.getExe pkgs.sqlite}
    shopt -s nullglob
    found=0
    for db in "$HOME"/.config/zen/*/permissions.sqlite "$HOME"/.zen/*/permissions.sqlite; do
      found=1
      if "$sqlite" -cmd '.timeout 3000' "$db" ${lib.escapeShellArg sql}; then
        echo "zen: shortcuts blocked for Outlook/Teams in $db (restart Zen to apply)"
      else
        echo "zen: could not update $db (is Zen running? close it and rebuild)" >&2
      fi
    done
    if [ "$found" = 0 ]; then
      echo "zen: no permissions.sqlite yet; start Zen once and rebuild"
    fi
  '';
in
{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  home.activation.zenBlockShortcutOverrides = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${blockShortcutOverrides}
  '';
}
