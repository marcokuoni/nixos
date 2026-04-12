#!/usr/bin/env python3
"""
remarkable-sync: Two-way sync between a local folder and reMarkable Cloud.

Download (remote -> local):
  - Uploaded PDFs/EPUBs: extracted from .rmdoc as proper .pdf files
  - Native notebooks: kept as .rmdoc (reMarkable's archive format)
  - When tablet is connected via USB: all files downloaded as PDF via
    the USB web interface (perfect quality, tablet renders everything)

Upload (local -> remote):
  - PDF/EPUB files dropped into ~/remarkable/ are uploaded with rmapi put
  - Files deleted locally that were previously uploaded are removed remotely
"""

import argparse
import json
import logging
import os
import subprocess
import urllib.request
import zipfile
from pathlib import Path

SUPPORTED_UPLOAD_EXTENSIONS = {".pdf", ".epub"}
DEFAULT_SYNC_DIR = Path.home() / "remarkable"
DEFAULT_STATE_FILE = (
    Path.home() / ".local" / "share" / "remarkable-sync" / "state.json"
)
DEFAULT_RMAPI_BIN = "rmapi"
DEFAULT_REMOTE_ROOT = "/"
USB_BASE = "http://10.11.99.1"
USB_TIMEOUT = 5

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("remarkable-sync")


def usb_available():
    try:
        urllib.request.urlopen(USB_BASE, timeout=USB_TIMEOUT)
        return True
    except Exception:
        return False


def usb_list_docs():
    try:
        with urllib.request.urlopen(USB_BASE + "/documents/", timeout=USB_TIMEOUT) as r:
            return json.loads(r.read())
    except Exception as e:
        log.error("USB list failed: %s", e)
        return []


def usb_build_paths(items):
    by_id = {item["ID"]: item for item in items}

    def get_path(item_id):
        item = by_id.get(item_id)
        if not item:
            return ""
        parent = item.get("Parent", "")
        name = item.get("VissibleName", item_id)
        if parent and parent in by_id:
            return get_path(parent) + "/" + name
        return "/" + name

    return {
        get_path(item["ID"]): item
        for item in items
        if item.get("Type") == "DocumentType"
    }


def usb_download_pdf(doc_id, dest_path):
    url = f"{USB_BASE}/download/{doc_id}/pdf"
    try:
        with urllib.request.urlopen(url, timeout=120) as r:
            data = r.read()
        if len(data) < 500:
            log.warning("USB PDF too small (%d bytes) for %s", len(data), doc_id)
            return False
        dest_path.write_bytes(data)
        return True
    except Exception as e:
        log.error("USB download failed for %s: %s", doc_id, e)
        return False


def rmapi_run(args, rmapi_bin, capture=False):
    cmd = [rmapi_bin] + args
    log.debug("$ %s", " ".join(str(c) for c in cmd))
    return subprocess.run(cmd, capture_output=capture, text=True)


def _ls_recursive(rmapi_bin, path, docs):
    result = rmapi_run(["ls", path], rmapi_bin, capture=True)
    if result.returncode != 0:
        log.warning("ls failed for %s: %s", path, result.stderr.strip())
        return
    for line in result.stdout.splitlines():
        line = line.strip()
        if not line or not (line.startswith("[d]") or line.startswith("[f]")):
            continue
        kind, name = line[:3], line[3:].strip()
        if not name:
            continue
        child_path = path.rstrip("/") + "/" + name
        if kind == "[d]":
            if name.lower() != "trash":
                _ls_recursive(rmapi_bin, child_path, docs)
        else:
            docs[child_path] = name


def list_remote(rmapi_bin, remote_root):
    docs = {}
    _ls_recursive(rmapi_bin, remote_root, docs)
    return docs


def extract_pdf_from_rmdoc(rmdoc_path, clean_name, dest_dir):
    """
    Try to extract an embedded PDF from a .rmdoc zip.
    Works for uploaded PDFs/EPUBs; returns None for native notebooks.
    """
    try:
        with zipfile.ZipFile(rmdoc_path) as zf:
            pdf_members = [m for m in zf.namelist() if m.lower().endswith(".pdf")]
            if not pdf_members:
                return None
            out_path = dest_dir / (clean_name + ".pdf")
            out_path.write_bytes(zf.read(pdf_members[0]))
            return out_path
    except zipfile.BadZipFile as e:
        log.error("Bad zip %s: %s", rmdoc_path.name, e)
        return None


def load_state(state_file):
    if state_file.exists():
        with open(state_file) as f:
            return json.load(f)
    return {"local_uploaded": {}, "remote_seen": {}}


def save_state(state, state_file):
    state_file.parent.mkdir(parents=True, exist_ok=True)
    with open(state_file, "w") as f:
        json.dump(state, f, indent=2)


def scan_local_uploads(sync_dir):
    result = {}
    for path in sync_dir.rglob("*"):
        if path.is_file() and path.suffix.lower() in SUPPORTED_UPLOAD_EXTENSIONS:
            rel = str(path.relative_to(sync_dir))
            result[rel] = path.stat().st_mtime
    return result


def sync(sync_dir, state_file, rmapi_bin, remote_root, dry_run):
    sync_dir.mkdir(parents=True, exist_ok=True)
    state = load_state(state_file)
    prev_uploaded = state.get("local_uploaded", {})
    prev_remote = state.get("remote_seen", {})

    use_usb = usb_available()
    if use_usb:
        log.info("Tablet connected via USB — downloading PDFs via web interface")
    else:
        log.info("No USB connection — using cloud (rmapi)")

    log.info("Scanning reMarkable cloud...")
    cloud_docs = list_remote(rmapi_bin, remote_root)
    log.info("Found %d document(s) on reMarkable", len(cloud_docs))

    usb_docs = {}
    if use_usb:
        usb_docs = usb_build_paths(usb_list_docs())

    for doc_path, doc_name in sorted(cloud_docs.items()):
        if doc_path in prev_remote:
            log.debug("Already known: %s", doc_path)
            continue

        rel_parts = doc_path.lstrip("/").split("/")
        local_dir = sync_dir
        if len(rel_parts) > 1:
            local_dir = sync_dir / "/".join(rel_parts[:-1])

        clean_name = doc_name[:-4] if doc_name.lower().endswith(".pdf") else doc_name
        pdf_path = local_dir / (clean_name + ".pdf")
        rmdoc_path = local_dir / (clean_name + ".rmdoc")

        if pdf_path.exists() or rmdoc_path.exists():
            log.debug("Already on disk: %s", clean_name)
            continue

        log.info("DOWNLOAD  %s", doc_path)
        if dry_run:
            continue

        local_dir.mkdir(parents=True, exist_ok=True)
        downloaded_as_pdf = False

        if use_usb:
            usb_match = next(
                (item for p, item in usb_docs.items()
                 if p.rsplit("/", 1)[-1] == doc_name),
                None
            )
            if usb_match:
                log.info("  via USB PDF export")
                downloaded_as_pdf = usb_download_pdf(usb_match["ID"], pdf_path)
                if downloaded_as_pdf:
                    log.info("  -> %s", pdf_path.name)

        if not downloaded_as_pdf:
            old_cwd = os.getcwd()
            try:
                os.chdir(local_dir)
                result = rmapi_run(["get", doc_path], rmapi_bin, capture=True)
                log.debug("get stdout: %s", result.stdout.strip())
                log.debug("get stderr: %s", result.stderr.strip())
            finally:
                os.chdir(old_cwd)

            if result.returncode != 0:
                log.error("get failed for %s: %s", doc_path, result.stderr.strip())
                continue

            dl = local_dir / (doc_name + ".rmdoc")
            if not dl.exists():
                candidates = sorted(
                    local_dir.glob("*.rmdoc"), key=lambda p: p.stat().st_mtime
                )
                dl = candidates[-1] if candidates else None

            if not dl:
                log.error("No rmdoc found after downloading %s", doc_path)
                continue

            pdf = extract_pdf_from_rmdoc(dl, clean_name, local_dir)
            if pdf:
                dl.unlink()
                log.info("  -> extracted PDF: %s", pdf.name)
            else:
                final = local_dir / (clean_name + ".rmdoc")
                if dl != final:
                    dl.rename(final)
                log.info("  -> notebook: %s (plug in USB for PDF)", final.name)

    log.info("Scanning local folder: %s", sync_dir)
    current_uploaded = scan_local_uploads(sync_dir)
    remote_stems = {p.rsplit("/", 1)[-1] for p in cloud_docs}

    new_local = set(current_uploaded) - set(prev_uploaded)
    for rel in sorted(new_local):
        local_path = sync_dir / rel
        if local_path.stem in remote_stems:
            log.debug("Skipping upload (already remote): %s", rel)
            continue
        parts = Path(rel).parts
        remote_dir = remote_root
        if len(parts) > 1:
            remote_dir = remote_root.rstrip("/") + "/" + "/".join(parts[:-1])
        log.info("UPLOAD  %s  ->  %s", rel, remote_dir)
        if not dry_run:
            result = rmapi_run(
                ["put", str(local_path), remote_dir], rmapi_bin, capture=True
            )
            if result.returncode != 0:
                log.error("Upload failed for %s: %s", rel, result.stderr.strip())

    deleted_local = set(prev_uploaded) - set(current_uploaded)
    for rel in sorted(deleted_local):
        stem = Path(rel).stem
        for doc_path in [p for p in cloud_docs if p.rsplit("/", 1)[-1] == stem]:
            log.info("DELETE remote  %s", doc_path)
            if not dry_run:
                result = rmapi_run(["rm", doc_path], rmapi_bin, capture=True)
                if result.returncode != 0:
                    log.warning("Delete failed %s: %s", doc_path, result.stderr.strip())

    if not dry_run:
        state["local_uploaded"] = scan_local_uploads(sync_dir)
        state["remote_seen"] = cloud_docs
        save_state(state, state_file)
        log.info("State saved -> %s", state_file)
    else:
        log.info("[dry-run] state NOT saved")

    log.info("Sync complete.")


def main():
    parser = argparse.ArgumentParser(
        description="Two-way sync: local folder <-> reMarkable cloud."
    )
    parser.add_argument(
        "--sync-dir", type=Path,
        default=os.environ.get("REMARKABLE_SYNC_DIR", DEFAULT_SYNC_DIR),
    )
    parser.add_argument(
        "--state-file", type=Path,
        default=os.environ.get("REMARKABLE_STATE_FILE", DEFAULT_STATE_FILE),
    )
    parser.add_argument(
        "--rmapi",
        default=os.environ.get("RMAPI_BIN", DEFAULT_RMAPI_BIN),
    )
    parser.add_argument(
        "--remote-root",
        default=os.environ.get("REMARKABLE_REMOTE_ROOT", DEFAULT_REMOTE_ROOT),
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--verbose", "-v", action="store_true")

    args = parser.parse_args()
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    if args.dry_run:
        log.info("=== DRY RUN - no changes will be made ===")

    sync(
        sync_dir=args.sync_dir,
        state_file=args.state_file,
        rmapi_bin=args.rmapi,
        remote_root=args.remote_root,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    main()
