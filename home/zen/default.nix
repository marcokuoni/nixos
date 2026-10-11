{ lib, pkgs, ... }:
let
  # Zen shortcuts that must always win over web pages (Outlook, Teams, ...).
  #
  # Zen/Firefox lets a page swallow a shortcut via preventDefault() unless the
  # <key> element carries reserved="true". A reserved key is handled by the
  # browser and never dispatched to the page; every other key still reaches
  # the page as usual. Zen persists that flag per shortcut in
  # zen-keyboard-shortcuts.json, so we pin bindings + reserved there.
  digits = map toString (lib.range 1 9);

  # Ctrl+Alt+N -> workspace N
  workspaceKeys = map (n: {
    id = "zen-workspace-switch-${n}";
    key = n;
    modifiers = {
      control = false;
      alt = true;
      shift = false;
      meta = false;
      accel = true;
    };
  }) digits;

  # Alt+N -> tab N (Alt+9 = last tab, like stock Firefox on Linux)
  tabKeys = map (n: {
    id = if n == "9" then "key_selectLastTab" else "key_selectTab${n}";
    key = n;
    modifiers = {
      control = false;
      alt = true;
      shift = false;
      meta = false;
      accel = false;
    };
  }) digits;

  pinned = builtins.toJSON (workspaceKeys ++ tabKeys);

  pinShortcuts = pkgs.writeShellScript "zen-pin-shortcuts" ''
    set -u
    jq=${lib.getExe pkgs.jq}
    shopt -s nullglob
    found=0
    for f in "$HOME"/.config/zen/*/zen-keyboard-shortcuts.json "$HOME"/.zen/*/zen-keyboard-shortcuts.json; do
      found=1
      tmp="$(mktemp)"
      # Firefox keys without an id are stored with "id": null, so always
      # compare via (.id // "") instead of indexing with .id directly.
      if "$jq" --argjson pin '${pinned}' '
        ($pin | map({ (.id): . }) | add) as $p
        | ([.shortcuts[] | (.id // "")]) as $have
        | .shortcuts |= map(
            (.id // "") as $i
            | if ($p | has($i)) then
                . + {
                  key: $p[$i].key,
                  keycode: "",
                  modifiers: $p[$i].modifiers,
                  disabled: false,
                  reserved: true
                }
              else . end
          )
        # Workspace switches are missing from some profiles: add them.
        | .shortcuts += [
            $pin[]
            | select(.id | startswith("zen-workspace-switch-"))
            | select(.id as $i | $have | index($i) | not)
            | {
                id,
                key,
                keycode: "",
                group: "zen-workspace",
                l10nId: ("zen-workspace-shortcut-switch-" + .key),
                modifiers,
                action: ("cmd_zenWorkspaceSwitch" + .key),
                disabled: false,
                reserved: true,
                internal: false
              }
          ]
      ' "$f" > "$tmp" && [ -s "$tmp" ]; then
        if ! cmp -s "$tmp" "$f"; then
          cat "$tmp" > "$f"
          echo "zen: pinned Ctrl+Alt+1-9 / Alt+1-9 in $f (restart Zen to apply)"
        fi
      else
        echo "zen: could not update $f, left unchanged" >&2
      fi
      rm -f "$tmp"
    done
    if [ "$found" = 0 ]; then
      echo "zen: no zen-keyboard-shortcuts.json yet; start Zen once and rebuild"
    fi
  '';
in
{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  home.activation.zenPinShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pinShortcuts}
  '';
}
