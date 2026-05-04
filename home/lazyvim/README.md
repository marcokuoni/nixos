# Research Stack — Obsidian + Zotero + Typst auf NixOS

Eine zusammenhängende Forschungs- und Schreib-Umgebung. Alles deklarativ in Nix,
Snippets und Keymaps inklusive.

## Was drinsteckt

| Tool            | Rolle                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **Zotero**      | Literaturverwaltung, PDF-Annotation. Single source of truth via `library.bib`. |
| **Obsidian**    | Notizen, Tasks, Daily Notes, CalDAV-Kalender (über Plugins).          |
| **Typst**       | Compiler für wissenschaftliche Paper. Liest dieselbe `.bib`.          |
| **Tinymist**    | Typst LSP — Live-Preview, Completion, Hover, Goto-Definition.          |
| **Typstyle**    | Typst-Formatter, eingebunden über die LSP.                             |
| **typst-preview** | Browser-basierte Live-Preview mit bidirektionalem Cursor-Sync.       |
| **obsidian.nvim** | Vault-Editing direkt aus Neovim (Wiki-Links, Backlinks, Daily Notes). |
| **LuaSnip**     | Snippet-Engine. Snippets liegen in `~/.config/nvim/luasnip-snippets/`. |

## Verzeichnis-Layout

Erwarteter Aufbau im Home:

```
~/research/
├── library.bib              # Better BibTeX schreibt hier rein (Zotero-Export)
├── pdfs/                    # Zotero linked-attachment dir
├── vault/                   # Obsidian Vault
│   ├── daily/               # Daily Notes (YYYY-MM-DD)
│   ├── weekly/              # Wochennotizen (YYYY-Www)
│   ├── monthly/             # Monatsnotizen (YYYY-MM)
│   ├── literature/          # Eine Notiz pro Paper
│   ├── projects/            # Projekt-Notizen mit eigenen Task-Boards
│   ├── calendar/local/      # Full Calendar lokale Events
│   └── templates/           # Templater-Templates
└── papers/
    └── <projekt>/
        ├── paper.typ
        └── refs.bib         # Symlink → ../../library.bib
```

Erstellen mit:

```bash
mkdir -p ~/research/{pdfs,vault/{daily,weekly,monthly,literature,projects,calendar/local,templates},papers}
```

## Setup-Reihenfolge

### 1. NixOS-Config aktivieren

Diese Datei (`nixvim.nix`) in dein Home-Manager-Modul einbinden, dann:

```bash
sudo nixos-rebuild switch --flake '.#laptop' --impure
```

Das installiert: `obsidian`, `zotero`, `typst`, `tinymist`, `typstyle`, `pandoc`,
`zathura`. Außerdem werden alle Snippets nach `~/.config/nvim/luasnip-snippets/`
gelegt (read-only, im Nix-Store).

### 2. Zotero + Better BibTeX

1. Zotero starten
2. Better BibTeX von <https://retorque.re/zotero-better-bibtex/> als `.xpi`
   herunterladen, in Zotero per Drag-and-Drop ins Add-ons-Fenster ziehen
3. Edit → Settings → Advanced → Files and Folders → Linked Attachment Base
   Directory: `~/research/pdfs`
4. Rechtsklick auf die Library → *Export Library* → Format: *Better BibTeX*
   → *Keep updated* aktivieren → speichern als `~/research/library.bib`
5. Settings → Better BibTeX → Citation Keys: Format `[auth:lower][year]` (gibt
   dir Keys wie `smith2024`)

### 3. Tinymist Project Root

Wichtig damit Bibliographie-Symlinks funktionieren: Die nixvim-Config setzt
`--root /home/progressio/research`. Falls dein Username/Pfad anders ist,
in `nixvim.nix` unter `tinymist.settings.typstExtraArgs` anpassen.

### 4. Obsidian-Plugins installieren

In Obsidian → Settings → Community Plugins → Browse:

- **Tasks** (Clare Macrae)
- **Calendar** (Liam Cain)
- **Periodic Notes**
- **Templater**
- **Full Calendar** (Davis Haupt)
- **Citations** (Jan Hesters) — pointing at `~/research/library.bib`
- **Zotero Integration** — optional, für Annotation-Import

Optional: **Dataview**, **Style Settings**.

### 5. Full Calendar mit Nextcloud verbinden

1. Nextcloud → Settings → Security → "Neues App-Passwort erstellen" für Obsidian
2. Obsidian → Settings → Full Calendar → Add Calendar → CalDAV
3. URL: `https://deine-nextcloud.tld/remote.php/dav/calendars/USERNAME/`
4. App-Passwort eingeben → Import Calendars → gewünschte Kalender auswählen

Test: einen Termin in Nextcloud erstellen, ~30 Sekunden warten, sollte in
Obsidian Full Calendar View auftauchen — und umgekehrt.

### 6. Periodic Notes konfigurieren

Settings → Periodic Notes:

| Note     | Format          | Folder    | Template              |
| -------- | --------------- | --------- | --------------------- |
| Daily    | `YYYY-MM-DD`    | `daily`   | `templates/daily.md`  |
| Weekly   | `YYYY-[W]ww`    | `weekly`  | `templates/weekly.md` |
| Monthly  | `YYYY-MM`       | `monthly` | `templates/monthly.md`|

Den eingebauten Daily-Notes-Core-Plugin **deaktivieren**, sonst doppelte Trigger.

## Keybindings

`<leader>` ist standardmäßig `<Space>` in LazyVim.

### Typst Preview (`.typ`-Files)

| Keybind        | Aktion                              |
| -------------- | ----------------------------------- |
| `<leader>yp`   | Live-Preview im Browser öffnen      |
| `<leader>yt`   | Preview an/aus                      |
| `<leader>ys`   | Preview zur Cursorposition scrollen |

### Obsidian (`.md`-Files)

| Keybind        | Aktion                                |
| -------------- | ------------------------------------- |
| `<leader>oo`   | Quick Switch (Fuzzy-Suche Notizen)    |
| `<leader>os`   | Volltextsuche im Vault                |
| `<leader>ob`   | Backlinks zur aktuellen Notiz         |
| `<leader>on`   | Neue Notiz erstellen                  |
| `<leader>oT`   | Tag-Browser                           |
| `<leader>od`   | Heutige Daily Note öffnen             |
| `<leader>oy`   | Gestrige Daily Note                   |
| `<leader>ow`   | Liste aller Daily Notes               |
| `<leader>of`   | Wikilink unter Cursor folgen          |
| `<leader>op`   | Bild aus Clipboard einfügen           |
| `<leader>ot`   | Template einfügen                     |

### LuaSnip (überall, aktiv im Insert-Modus)

| Keybind   | Modus           | Aktion                           |
| --------- | --------------- | -------------------------------- |
| `<Tab>`   | Insert          | Snippet expandieren oder springen |
| `<Tab>`   | Select          | Zum nächsten Placeholder         |
| `<S-Tab>` | Insert + Select | Zum vorherigen Placeholder       |

### Snacks Terminal

| Keybind      | Aktion           |
| ------------ | ---------------- |
| `<leader>T`  | Terminal toggle  |

(Bewusst auf großem `T`, weil `<leader>t` von der Typst-Familie genutzt wird.)

### DAP Debugging

| Keybind | Aktion           |
| ------- | ---------------- |
| `<F5>`  | Continue         |
| `<F9>`  | Toggle Breakpoint|
| `<F10>` | Step over        |
| `<F11>` | Step into        |
| `<F12>` | Step out         |

## Snippets

Snippets liegen in `~/.config/nvim/luasnip-snippets/<filetype>.lua` (read-only,
deklarativ in Nix). Trigger: Kürzel im Insert-Modus tippen, dann `<Tab>`.

### Typst (`typst.lua`)

| Kürzel   | Ergibt                                                              |
| -------- | ------------------------------------------------------------------- |
| `mm`     | Inline-Math `$...$`                                                  |
| `dm`     | Display-Math `$ ... $`                                               |
| `cite`   | `@key`                                                               |
| `fig`    | `#figure(image(...), caption: [...]) <fig:...>` Block                |
| `paper`  | Vollständiges Paper-Skelett mit Bibliographie                        |

### Markdown / Obsidian (`markdown.lua`)

| Kürzel   | Ergibt                                                              |
| -------- | ------------------------------------------------------------------- |
| `tt`     | Task fällig heute (`- [ ] X 📅 YYYY-MM-DD`)                         |
| `tm`     | Task fällig morgen                                                   |
| `tw`     | Task fällig in 7 Tagen                                               |
| `td`     | Task mit eingebbarem Datum                                           |
| `tp`     | Task hohe Priorität (⏫) mit Datum                                   |
| `tf`     | Task mit Start- (🛫) und Fälligkeitsdatum (📅)                      |
| `dt`     | Wikilink zur heutigen Daily Note                                     |
| `tr`     | Termin-Eintrag: Uhrzeit + Titel + Kontext-Link                       |

## Daily Loop

**Morgens:**
- Obsidian öffnen → Dashboard zeigt fällige Tasks
- Calendar Sidebar zeigt heutige Termine
- `<leader>od` (in nvim) öffnet Daily Note für heute

**Während des Tages:**
- Paper in Zotero ablegen → `library.bib` updated automatisch
- Notizen in Obsidian/nvim → Tasks mit `tt<Tab>`, `tw<Tab>`, etc. droppen
- Tasks landen wo der Kontext liegt, tauchen im Dashboard auf
- Termine in Thunderbird/Telefon/Obsidian → CalDAV synced alle Richtungen

**Schreiben:**
- `nvim ~/research/papers/foo/paper.typ`
- `<leader>yp` → Browser-Preview, Cursor-Sync läuft
- `:w` → tinymist exportiert PDF
- Citation Keys per `cite<Tab>` → `@smith2024` (gleiche Keys wie in Obsidian)

**Sonntags:**
- Wochennotiz öffnen → Wochenrückblick + Planung

## Häufige Fehler

**Typst Preview leer:**
- Cli-Test: `typst compile paper.typ`. Wenn das errors wirft → das ist die Ursache
- Bibliographie-Datei fehlt? → Symlink prüfen
- Erste Compilation lädt Templates aus dem Typst-Package-Registry; nach
  `typst compile` aus der Shell ist's gecached

**`failed to load file (access denied)`:**
- Tinymist Sandbox-Problem
- `--root`-Pfad in `nixvim.nix` muss deinen Pfad enthalten
- Symlinks resolven werden — Target muss innerhalb des Roots liegen

**Obsidian: "module 'cmp' not found":**
- Sollte mit der aktuellen Config behoben sein (`nvim_cmp = false`)
- Falls doch wieder: Plugin-Reihenfolge prüfen, `:Lazy reload obsidian.nvim`

**Snippets feuern nicht:**
- `:LuaSnipListAvailable` zeigt was für den aktuellen Filetype geladen ist
- Filetype korrekt? `:set ft?` muss `typst` oder `markdown` sein
- LuaSnip geladen? `:Lazy` → LuaSnip sollte als loaded markiert sein

## Snippets ändern

Da Snippets in `extraFiles` liegen, ist Editing = `nixos-rebuild`. Workflow:

1. `nixvim.nix` editieren, im `extraFiles`-Block den Snippet-Inhalt ändern
2. `sudo nixos-rebuild switch --flake '.#laptop' --impure`
3. nvim neu starten oder `:Lazy reload LuaSnip`

Wer das öfter machen will: `extraFiles`-Block für Snippets weglassen und in
LuaSnip's Loader einen writable Pfad eintragen, z.B.
`~/.config/luasnip-snippets-user`. Dann werden Änderungen ohne rebuild aktiv.

## Sync zwischen Geräten

- **Termine**: Über CalDAV via Nextcloud bidirektional auf allen Geräten
- **Vault**: Syncthing oder Nextcloud Sync
- **Library**: `library.bib` und PDFs syncen ebenfalls über Syncthing/Nextcloud
