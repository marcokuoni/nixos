# remarkable-sync

A NixOS setup for two-way sync between a local Linux folder and your reMarkable 2 tablet, plus automatic conversion of handwritten notebooks to PDF.

## Overview

Two services work together:

- **`remarkable-sync`** — syncs files between `~/remarkable/` and the reMarkable cloud every 5 minutes
- **`rmdoc-to-pdf`** — converts handwritten notebooks (`.rmdoc`) to PDFs in `~/remarkable-pdf/`

```
reMarkable cloud
      ↕  (rmapi)
~/remarkable/          ← uploaded PDFs/EPUBs extracted as .pdf
                          native notebooks kept as .rmdoc
      ↓  (rmc + cairosvg)
~/remarkable-pdf/      ← all notebooks converted to readable PDFs
```

When your tablet is connected via **USB**, the sync automatically downloads perfect PDFs directly from the tablet for everything — no conversion needed.

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
journalctl -u remarkable-sync.service -f

sudo systemctl start rmdoc-to-pdf.service
journalctl -u rmdoc-to-pdf.service -f
```

---

## How sync works

### Cloud mode (WiFi, no USB)

- **Uploaded PDFs/EPUBs** → extracted from `.rmdoc` and saved as `.pdf`
- **Native notebooks** → kept as `.rmdoc` archive files
- **Local PDF/EPUB dropped in `~/remarkable/`** → uploaded to reMarkable cloud
- **Local file deleted** → deleted from cloud (only files you uploaded)

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

The `rmdoc-to-pdf` service processes every `.rmdoc` file in `~/remarkable/` and converts it to a PDF in `~/remarkable-pdf/`, preserving folder structure.

Pipeline per notebook:
1. **Unzip** the `.rmdoc` archive
2. **Convert each `.rm` page to SVG** using `rmc` (supports reMarkable v6 format)
3. **Convert each SVG to PDF** using `cairosvg` (pure Python, no binary deps)
4. **Merge all pages** into a single PDF using `pypdf`

Pages that `rmc` cannot parse (some newer firmware 3.26 format blocks) are skipped — the PDF will have gaps for those pages. Quality is good for most content.

State is tracked in `~/remarkable-pdf/.rmdoc-to-pdf-state.json` — only modified notebooks are reconverted on subsequent runs.

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

# View logs
journalctl -u remarkable-sync.service
journalctl -u rmdoc-to-pdf.service

# Force immediate sync
sudo systemctl start remarkable-sync.service

# Force immediate conversion
sudo systemctl start rmdoc-to-pdf.service

# Force re-conversion of all notebooks
rm ~/remarkable-pdf/.rmdoc-to-pdf-state.json
sudo systemctl start rmdoc-to-pdf.service

# Re-download everything from scratch
rm ~/.local/share/remarkable-sync/state.json
sudo systemctl start remarkable-sync.service

# Dry run (see what would happen)
REMARKABLE_SYNC_DIR=~/remarkable \
REMARKABLE_STATE_FILE=~/.local/share/remarkable-sync/state.json \
RMAPI_BIN=$(which rmapi) \
  python3 /etc/nixos/remarkable-sync.py --dry-run --verbose
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

**"Already on disk" but folder is empty**
Check for hidden files or subfolders:
```bash
find ~/remarkable -maxdepth 3 2>/dev/null
ls -la ~/remarkable/
```

**Timer fires but sync missed while suspended**
The timers use `Persistent = true` — missed runs fire immediately on next wake.
