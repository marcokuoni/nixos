# remarkable-sync

A NixOS setup for two-way sync between a local Linux folder and your reMarkable 2 tablet, plus automatic conversion of handwritten notebooks and annotated PDFs to readable PDFs.

Two services work together:

- **`remarkable-sync`** — syncs files between `~/remarkable/` and the reMarkable cloud every 5 minutes, automatically detecting when you've added annotations on the tablet and re-downloading updated files
- **`rmdoc-to-pdf`** — converts all `.rmdoc` files (notebooks and annotated PDFs) to readable PDFs in `~/remarkable-pdf/`, starts automatically after each sync

```
reMarkable cloud
      ↕  (rmapi)
~/remarkable/          ← all documents kept as .rmdoc
                          (contains original + any annotations)
      ↓  (rmc + cairosvg)
~/remarkable-pdf/      ← PDFs rendered with annotations overlaid
```

When connected via USB, `~/remarkable/` receives proper PDFs directly from the tablet (perfect quality, bypasses rmc entirely).

---

## Requirements

- A **reMarkable Connect subscription** (or free cloud account) — rmapi uses the reMarkable cloud API
- Run `rmapi` **once manually** after first install to authenticate (see step 4)
- For USB mode: tablet connected via USB cable, USB web interface enabled on device

---

## Files

| File | Description |
|---|---|
| `remarkable-sync.nix` | NixOS module for the sync service |
| `remarkable-sync.py` | Sync script (rmapi cloud ↔ local folder) |
| `rmdoc-to-pdf.nix` | NixOS module for the notebook converter |
| `rmdoc-to-pdf.py` | Converter script (rmdoc → SVG via rmc → PDF via cairosvg) |

---

## Setup

### 1. Copy files to your NixOS config

```bash
cp remarkable-sync.nix remarkable-sync.py \
   rmdoc-to-pdf.nix rmdoc-to-pdf.py \
   /etc/nixos/
```

### 2. Add to `configuration.nix`

```nix
imports = [
  ./remarkable-sync.nix
  ./rmdoc-to-pdf.nix
];

services.remarkable-sync = {
  enable   = true;
  user     = "youruser";
  # syncDir  = "/home/youruser/remarkable";     # default
  # interval = "5min";                           # default
};

services.rmdoc-to-pdf = {
  enable    = true;
  user      = "youruser";
  # inputDir  = "/home/youruser/remarkable";     # default
  # outputDir = "/home/youruser/remarkable-pdf"; # default
  # interval  = "10min";                         # default
};
```

### 3. Rebuild

```bash
sudo nixos-rebuild switch
```

### 4. Authenticate rmapi (one-time)

```bash
# Run as your normal user
rmapi
# Follow the prompt — visit https://my.remarkable.com/connect/desktop
# and paste the one-time code
```

The token is stored in `~/.config/rmapi/` and never expires unless revoked.

### 5. Start manually to verify

```bash
sudo systemctl start remarkable-sync.service
journalctl -u remarkable-sync.service -u rmdoc-to-pdf.service -f
```

---

## How sync works

### Cloud mode (WiFi, no USB)

- **All documents** → kept as `.rmdoc` (lossless archive containing original + annotations)
- **Annotations added on tablet** → re-downloaded automatically on next sync (remote mtime checked via `rmapi stat`, stored in state to avoid redundant re-downloads)
- **New pages added to a notebook** → `.rmdoc` updated on next sync
- **Local PDF/EPUB dropped in `~/remarkable/`** → uploaded to reMarkable cloud
- **Local file deleted** → deleted from cloud (only files you uploaded)

Readable PDFs with annotations are produced by `rmdoc-to-pdf` in `~/remarkable-pdf/`.

### USB mode (tablet plugged in)

When the tablet is connected via USB and the USB web interface is enabled:

- **All documents** (including notebooks) → downloaded as perfect PDFs rendered by the tablet itself
- **Existing `.rmdoc` files are automatically upgraded** to proper PDFs on the next sync
- **Downloaded PDFs are never uploaded back** to the tablet — only files you explicitly drop into the folder get uploaded
- Enable in tablet: **Settings → Storage → USB web interface**

Step by step when USB is connected:
1. Script detects `http://10.11.99.1` is reachable
2. Calls `GET http://10.11.99.1/documents/` to get all documents with their UUIDs
3. For each new or previously `.rmdoc` document, calls `GET http://10.11.99.1/download/<uuid>/pdf`
4. The **tablet itself renders the PDF** — perfect quality, no format issues
5. Saves as `DocName.pdf` in `~/remarkable/`

---

## How notebook conversion works

The `rmdoc-to-pdf` service processes every `.rmdoc` file in `~/remarkable/` and converts it to a PDF in `~/remarkable-pdf/`, preserving folder structure. This works for both native notebooks and annotated PDFs.

### Native notebooks (no original PDF inside)

1. Read page order from `.content` file (`cPages.pages[].id`)
2. Convert each `.rm` page to SVG using `rmc`
3. Convert each SVG to PDF using `cairosvg`
4. Merge all pages into a single PDF using `pypdf`

Pages that `rmc` cannot parse (some newer firmware 3.26 format blocks) are skipped — the PDF will have gaps for those pages.

### Annotated PDFs (original PDF inside rmdoc)

1. Extract the original PDF from the rmdoc archive
2. Read page mapping from `.content` (`cPages.pages[].redir.value` = original PDF page index)
3. For each annotated page, convert the `.rm` strokes to SVG using `rmc`
4. Rewrite the SVG to use the full reMarkable canvas coordinate space
5. Overlay the annotation onto the correct original PDF page using `pypdf`

> **Note on annotation positioning:** The annotation overlay uses empirically calibrated constants (`scale=0.75, tx=pw/2, ty=ph*0.285`) derived for the reMarkable 2 on A4 PDFs. The offset is caused by how `rmc` and `cairosvg` handle the reMarkable's internal coordinate system — `rmc` outputs SVG with a negative x viewBox offset, and `cairosvg` renders at 75% of the input size regardless of specified dimensions. These constants correct for both effects. Positioning may be slightly off on non-A4 PDFs or different reMarkable models. For perfect annotation rendering, use USB mode — the tablet renders its own files flawlessly.

State is tracked in `~/remarkable-pdf/.rmdoc-to-pdf-state.json` — only modified files are reconverted on subsequent runs.

---

## Options

### `services.remarkable-sync`

| Option | Default | Description |
|---|---|---|
| `enable` | `false` | Enable the service |
| `user` | *(required)* | Your username |
| `syncDir` | `~/remarkable` | Local sync folder |
| `stateFile` | `~/.local/share/remarkable-sync/state.json` | State tracking |
| `remoteRoot` | `/` | Remote root folder on reMarkable |
| `interval` | `5min` | Sync frequency |
| `extraArgs` | `[]` | Extra CLI args (e.g. `["--verbose"]`) |

### `services.rmdoc-to-pdf`

| Option | Default | Description |
|---|---|---|
| `enable` | `false` | Enable the service |
| `user` | *(required)* | Your username |
| `inputDir` | `~/remarkable` | Source of `.rmdoc` files |
| `outputDir` | `~/remarkable-pdf` | PDF output folder |
| `interval` | `10min` | Conversion frequency |
| `extraArgs` | `[]` | Extra CLI args (e.g. `["--verbose", "--force"]`) |

---

## Useful commands

```bash
# Check timer status
systemctl status remarkable-sync.timer
systemctl status rmdoc-to-pdf.timer

# View logs (both services together)
journalctl -u remarkable-sync.service -u rmdoc-to-pdf.service -f

# Force immediate sync (rmdoc-to-pdf starts automatically after)
sudo systemctl start remarkable-sync.service

# Force immediate conversion only (without sync)
sudo systemctl start rmdoc-to-pdf.service

# Force re-conversion of all notebooks
rm ~/remarkable-pdf/.rmdoc-to-pdf-state.json
sudo systemctl start rmdoc-to-pdf.service

# Re-download everything from scratch
rm ~/.local/share/remarkable-sync/state.json
sudo systemctl start remarkable-sync.service
```

---

## Troubleshooting

**Sync completes instantly but folder is empty**
The state file thinks everything is already synced. Reset it:
```bash
rm ~/.local/share/remarkable-sync/state.json
sudo systemctl start remarkable-sync.service
```

**Authentication errors**
Token may have been revoked. Re-run `rmapi` interactively to re-authenticate.

**Notebooks produce PDFs with blank pages**
Some pages use reMarkable firmware 3.26 format blocks that `rmscene 0.8` cannot parse. Connect via USB for perfect PDFs — the tablet renders its own files flawlessly.

**Annotations are slightly misaligned on the PDF**
See the note in "How notebook conversion works" above. The calibrated offsets work well for A4 PDFs on reMarkable 2. For perfect alignment, use USB mode.

**File keeps re-downloading every sync**
The remote mtime state may be corrupt. Reset:
```bash
rm ~/.local/share/remarkable-sync/state.json
sudo systemctl start remarkable-sync.service
```

**Timer fires but sync missed while suspended**
The timers use `Persistent = true` — missed runs fire immediately on next wake.
