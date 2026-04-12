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
    Convert a .rmdoc to PDF:
    1. Unzip the rmdoc
    2. Convert each .rm page to SVG with rmc
    3. Convert each SVG to PDF with inkscape
    4. Merge all PDF pages into one PDF
    Returns True on success.
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)

        # Unzip rmdoc
        try:
            with zipfile.ZipFile(rmdoc_path) as zf:
                zf.extractall(tmpdir)
        except zipfile.BadZipFile as e:
            log.error("Bad zip %s: %s", rmdoc_path.name, e)
            return False

        # Find all .rm files and sort them (page order)
        rm_files = sorted(tmpdir.rglob("*.rm"))
        if not rm_files:
            log.warning("No .rm files in %s", rmdoc_path.name)
            return False

        log.info("  %d page(s) found", len(rm_files))

        page_pdfs = []
        for i, rm_file in enumerate(rm_files):
            svg_file = tmpdir / f"page_{i:04d}.svg"
            page_pdf = tmpdir / f"page_{i:04d}.pdf"

            # rm -> svg
            result = rmc_svg(rm_file, svg_file, python_bin)
            if not svg_file.exists() or svg_file.stat().st_size == 0:
                log.warning("  page %d: rmc produced no SVG (rc=%d): %s",
                            i, result.returncode, result.stderr.strip()[:200])
                continue

            # svg -> pdf
            result = svg_to_pdf_page(svg_file, page_pdf, python_bin)
            if not page_pdf.exists() or page_pdf.stat().st_size == 0:
                log.warning("  page %d: inkscape produced no PDF (rc=%d): %s",
                            i, result.returncode, result.stderr.strip()[:100])
                continue

            log.debug("  page %d ok (%d bytes)", i, page_pdf.stat().st_size)
            page_pdfs.append(page_pdf)

        if not page_pdfs:
            log.warning("No pages converted for %s", rmdoc_path.name)
            return False

        # Merge pages
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
