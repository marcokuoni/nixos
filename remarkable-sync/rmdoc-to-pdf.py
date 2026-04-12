#!/usr/bin/env python3
"""
rmdoc-to-pdf: Convert reMarkable .rmdoc notebooks to PDFs using rmc (SVG pipeline).

Watches a source folder for .rmdoc files and converts them to PDFs in an output folder.
Skips files that have already been converted (based on mtime).

Usage:
  rmdoc-to-pdf --input ~/remarkable --output ~/remarkable-pdf
"""

import argparse
import json
import logging
import os
import subprocess
import tempfile
import zipfile
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("rmdoc-to-pdf")

STATE_FILE_NAME = ".rmdoc-to-pdf-state.json"


def load_state(output_dir):
    state_file = output_dir / STATE_FILE_NAME
    if state_file.exists():
        with open(state_file) as f:
            return json.load(f)
    return {}


def save_state(state, output_dir):
    state_file = output_dir / STATE_FILE_NAME
    with open(state_file, "w") as f:
        json.dump(state, f, indent=2)


def get_ordered_rm_files(tmpdir, doc_name):
    """
    Return .rm files in correct page order by reading the .content file.
    The .content JSON has a "pages" array with UUIDs in display order.
    Falls back to alphabetical sort if .content is missing or unreadable.
    """
    # Find the .content file (sits alongside the .rm files)
    content_files = list(tmpdir.rglob("*.content"))
    for cf in content_files:
        try:
            with open(cf) as f:
                data = json.load(f)
            pages = data.get("pages") or data.get("cPages", {}).get("pages", [])
            if not pages:
                continue
            # pages may be a list of UUID strings or dicts with an "id" key
            uuids = []
            for p in pages:
                if isinstance(p, str):
                    uuids.append(p)
                elif isinstance(p, dict):
                    uuids.append(p.get("id", ""))
            ordered = []
            for uuid in uuids:
                if not uuid:
                    continue
                matches = list(tmpdir.rglob(f"{uuid}.rm"))
                if matches:
                    ordered.append(matches[0])
            if ordered:
                log.debug("Page order from .content: %d pages", len(ordered))
                return ordered
        except Exception as e:
            log.debug("Could not read .content %s: %s", cf, e)

    # Fallback: alphabetical sort
    log.debug("No .content found for %s, using alphabetical order", doc_name)
    return sorted(tmpdir.rglob("*.rm"))


def rmc_svg(rm_file, svg_file, python_bin):
    """Convert a single .rm file to SVG using rmc."""
    rmc_script = (
        "import sys; from rmc.cli import cli; "
        "sys.exit(cli(standalone_mode=True))"
    )
    result = subprocess.run(
        [python_bin, "-c", rmc_script,
         "-t", "svg", "-o", str(svg_file), str(rm_file)],
        capture_output=True, text=True
    )
    return result


def svg_to_pdf_page(svg_file, pdf_file, python_bin):
    """Convert SVG to PDF using cairosvg (pure Python, no binary needed)."""
    script = (
        f"import cairosvg; "
        f"cairosvg.svg2pdf(url={repr(str(svg_file))}, "
        f"write_to={repr(str(pdf_file))})"
    )
    result = subprocess.run(
        [python_bin, "-c", script],
        capture_output=True, text=True
    )
    return result


def merge_pdfs(pdf_pages, output_pdf, python_bin):
    """Merge multiple PDF pages into one PDF using pypdf via python_bin."""
    import json
    pages_json = json.dumps([str(p) for p in pdf_pages])
    out_str = str(output_pdf)
    script = (
        f"import json, sys\n"
        f"from pypdf import PdfWriter\n"
        f"pages = json.loads({repr(pages_json)})\n"
        f"out = {repr(out_str)}\n"
        f"w = PdfWriter()\n"
        f"[w.append(p) for p in pages]\n"
        f"open(out, 'wb').write(b'') or w.write(open(out, 'wb'))\n"
    )
    result = subprocess.run(
        [python_bin, "-c", script],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip()[:300])


def convert_rmdoc(rmdoc_path, output_pdf, python_bin):
    """
    Convert a .rmdoc to PDF.

    Annotated PDFs: start with full original PDF, overlay .rm strokes per page.
    Native notebooks: convert each .rm page via rmc SVG pipeline.
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)
        try:
            with zipfile.ZipFile(rmdoc_path) as zf:
                zf.extractall(tmpdir)
        except zipfile.BadZipFile as e:
            log.error("Bad zip %s: %s", rmdoc_path.name, e)
            return False

        orig_pdfs = [m for m in tmpdir.rglob("*.pdf")]
        orig_pdf = orig_pdfs[0] if orig_pdfs else None

        # Build map: page_uuid -> original PDF page index (from redir.value)
        page_to_orig_idx = {}
        for cf in tmpdir.rglob("*.content"):
            try:
                with open(cf) as f:
                    data = json.load(f)
                for p in data.get("cPages", {}).get("pages", []):
                    uid = p.get("id", "")
                    redir = p.get("redir", {})
                    if isinstance(redir, dict) and "value" in redir:
                        page_to_orig_idx[uid] = redir["value"]
            except Exception as e:
                log.debug("Could not read .content %s: %s", cf, e)

        rm_files = get_ordered_rm_files(tmpdir, rmdoc_path.name)

        if orig_pdf and orig_pdf.exists():
            # Annotated PDF: overlay annotations on original PDF pages
            log.debug("  annotated PDF with %d annotation file(s)", len(rm_files))
            annot_map = {}
            for rm_file in rm_files:
                orig_idx = page_to_orig_idx.get(rm_file.stem)
                if orig_idx is None:
                    continue
                svg_file = tmpdir / f"annot_{orig_idx:04d}.svg"
                result = rmc_svg(rm_file, svg_file, python_bin)
                if svg_file.exists() and svg_file.stat().st_size > 0:
                    annot_map[orig_idx] = str(svg_file)
                else:
                    log.debug("  page %d: rmc produced no SVG", orig_idx)

            # Rewrite SVG to use full reMarkable canvas instead of stroke-bounded viewBox
            # reMarkable 2: 1404x1872 px at 226 DPI -> 447.29 x 596.39 points at 72 DPI
            rm_w = 1404 / 226 * 72
            rm_h = 1872 / 226 * 72
            patched_annot_map = {}
            for page_idx, svg_path in annot_map.items():
                import re as _re
                with open(svg_path) as f:
                    svg = f.read()
                body = _re.sub(r'<\?xml[^?]*\?>', '', svg)
                body = _re.sub(r'<svg[^>]+>', '', body, count=1).replace('</svg>', '')
                new_svg = (
                    f'<svg xmlns="http://www.w3.org/2000/svg" '
                    f'width="{rm_w}" height="{rm_h}" '
                    f'viewBox="0 0 {rm_w} {rm_h}">' +
                    body + '</svg>'
                )
                patched_path = str(svg_path) + '.patched.svg'
                with open(patched_path, 'w') as f:
                    f.write(new_svg)
                patched_annot_map[page_idx] = patched_path

            script = "\n".join([
                "from pypdf import PdfWriter, PdfReader, Transformation",
                "import cairosvg, io",
                f"orig = PdfReader({repr(str(orig_pdf))})",
                "w = PdfWriter()",
                f"annot_map = {repr(patched_annot_map)}",
                "for i, page in enumerate(orig.pages):",
                "    if i in annot_map:",
                "        pw = float(page.mediabox.width)",
                "        ph = float(page.mediabox.height)",
                "        pdf_bytes = cairosvg.svg2pdf(url=annot_map[i])",
                "        ap = PdfReader(io.BytesIO(pdf_bytes)).pages[0]",
                "        ap_w = float(ap.mediabox.width)",
                "        ap_h = float(ap.mediabox.height)",
                "        # reMarkable 2 annotation alignment:",
                "        # cairosvg renders RM canvas at 0.75x -> scale=0.75 restores it",
                "        # giving sx=pw/RM_W, sy=ph/RM_H (canvas fills PDF page exactly)",
                "        # tx=pw/2 corrects for cairosvg baking in the negative SVG viewBox x offset",
                "        # ty=ph*0.285 is empirically derived for reMarkable 2 on A4",
                "        scale = 0.75",
                "        sx = (pw / ap_w) * scale",
                "        sy = (ph / ap_h) * scale",
                "        tx = pw / 2",
                "        ty = ph * 0.285",
                "        ap.add_transformation(Transformation().scale(sx, sy).translate(tx, ty))",
                "        ap.mediabox.upper_right = (pw, ph)",
                "        ap.mediabox.lower_left = (0, 0)",
                "        page.merge_page(ap)",
                "    w.add_page(page)",
                f"w.write(open({repr(str(output_pdf))}, 'wb'))",
            ])
            result = subprocess.run([python_bin, "-c", script],
                                    capture_output=True, text=True)
            if result.returncode != 0:
                log.error("Annotated merge failed: %s", result.stderr.strip()[:300])
                return False
            if not output_pdf.exists() or output_pdf.stat().st_size < 100:
                log.error("Empty output for %s", rmdoc_path.name)
                return False
            log.info("  -> %s (%d bytes)", output_pdf.name, output_pdf.stat().st_size)
            return True

        else:
            # Native notebook: convert each .rm page via rmc
            if not rm_files:
                log.warning("No .rm files in %s", rmdoc_path.name)
                return False
            log.info("  %d page(s) found", len(rm_files))
            page_pdfs = []
            for i, rm_file in enumerate(rm_files):
                svg_file = tmpdir / f"page_{i:04d}.svg"
                page_pdf = tmpdir / f"page_{i:04d}.pdf"
                result = rmc_svg(rm_file, svg_file, python_bin)
                if not svg_file.exists() or svg_file.stat().st_size == 0:
                    log.warning("  page %d: rmc produced no SVG (rc=%d): %s",
                                i, result.returncode, result.stderr.strip()[:200])
                    continue
                result = svg_to_pdf_page(svg_file, page_pdf, python_bin)
                if not page_pdf.exists() or page_pdf.stat().st_size == 0:
                    log.warning("  page %d: cairosvg produced no PDF", i)
                    continue
                log.debug("  page %d ok (%d bytes)", i, page_pdf.stat().st_size)
                page_pdfs.append(page_pdf)

            if not page_pdfs:
                log.warning("No pages converted for %s", rmdoc_path.name)
                return False
            try:
                merge_pdfs(page_pdfs, output_pdf, python_bin)
                log.info("  -> %s (%d pages, %d bytes)",
                         output_pdf.name, len(page_pdfs), output_pdf.stat().st_size)
                return True
            except Exception as e:
                log.error("PDF merge failed for %s: %s", rmdoc_path.name, e)
                return False


def process(input_dir, output_dir, python_bin, force):
    output_dir.mkdir(parents=True, exist_ok=True)
    state = load_state(output_dir)

    rmdoc_files = list(input_dir.rglob("*.rmdoc"))
    if not rmdoc_files:
        log.info("No .rmdoc files found in %s", input_dir)
        return

    log.info("Found %d .rmdoc file(s)", len(rmdoc_files))

    for rmdoc_path in sorted(rmdoc_files):
        rel = str(rmdoc_path.relative_to(input_dir))
        mtime = rmdoc_path.stat().st_mtime
        stem = rmdoc_path.stem

        # Mirror folder structure in output
        rel_dir = rmdoc_path.parent.relative_to(input_dir)
        out_dir = output_dir / rel_dir
        out_dir.mkdir(parents=True, exist_ok=True)
        output_pdf = out_dir / (stem + ".pdf")

        # Skip if already converted and not modified
        if not force and rel in state and state[rel] == mtime:
            if output_pdf.exists():
                log.debug("Up to date: %s", stem)
                continue

        log.info("Converting: %s", stem)
        success = convert_rmdoc(rmdoc_path, output_pdf, python_bin)

        if success:
            state[rel] = mtime
        else:
            # Remove failed output
            output_pdf.unlink(missing_ok=True)

    save_state(state, output_dir)
    log.info("Done.")


def main():
    parser = argparse.ArgumentParser(
        description="Convert .rmdoc notebooks to PDFs via rmc SVG pipeline."
    )
    parser.add_argument(
        "--input", "-i", type=Path,
        default=Path.home() / "remarkable",
        help="Folder containing .rmdoc files (default: ~/remarkable)"
    )
    parser.add_argument(
        "--output", "-o", type=Path,
        default=Path.home() / "remarkable-pdf",
        help="Folder for output PDFs (default: ~/remarkable-pdf)"
    )
    parser.add_argument(
        "--python", type=str,
        default=os.environ.get("RMC_PYTHON", "python3"),
        help="Python interpreter with rmc installed"
    )
    parser.add_argument(
        "--force", "-f", action="store_true",
        help="Re-convert even if already up to date"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true"
    )

    args = parser.parse_args()
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    log.info("Input:  %s", args.input)
    log.info("Output: %s", args.output)

    process(args.input, args.output, args.python, args.force)


if __name__ == "__main__":
    main()
