# Scripts

A personal collection of Windows utility scripts for file compression, random measurement generation, AutoCAD drafting, and quick calculations.

Each folder is self-contained. All scripts are plain Python, batch, or AutoLISP — no build step required.

## File inventory

| Category | File | What it does | Requires |
| --- | --- | --- | --- |
| Compressors | `scripts/compressors/Compress_PNG_JPG_PDF.bat` | Recursively compresses JPG, PNG, and PDF files. Mirrors the folder tree into a `Compressed` folder, never modifies originals, and keeps the original when compression would make a file larger. | ImageMagick (Ghostscript for PDFs) |
| Compressors | `scripts/compressors/HEIC_to_JPG.bat` | Converts every HEIC/HEIF photo in the folder it sits in to JPG inside a `JPG` subfolder. | Python, Pillow, pillow-heif |
| Compressors | `scripts/compressors/convert_HEIC_to_JPG.py` | Conversion engine used by the batch file. Multi-process, skips files already converted, and reports a summary. | Python, Pillow, pillow-heif |
| Randomizers | `scripts/randomizers/random2cols.py` | Takes a pasted list of measurements and prints randomized Portside/Starboard columns (each value between `n - 0.3` and `n`). | Python |
| Randomizers | `scripts/randomizers/random4cols.py` | Same as above but produces four columns: Portside1, Starboard1, Portside2, Starboard2. | Python |
| Randomizers | `scripts/randomizers/Rina_m.py` | Interactive thickness generator. Asks for thickness, item count, type (web/flange), and points, then copies tab-separated rows to the clipboard. | Python (Windows `clip`) |
| AutoCAD | `scripts/autocad/AutoCAD_text03.lsp` | Adds the `RANDTHK` command: replaces selected TEXT/MTEXT values with randomized thickness readings around a base value. | AutoCAD |
| AutoCAD | `scripts/autocad/AutoCAD_text07.lsp` | Variant of the same `RANDTHK` command. Load one or the other — both define the same command name. | AutoCAD |
| AutoCAD | `scripts/autocad/RenumberSketches.lsp` | `RenumberSketches` command: sorts selected sketch labels left-to-right and top-to-bottom, then renumbers them from a starting number. | AutoCAD |
| Calculators | `scripts/calculators/angle_calc.py` | Calculates angle steel weight per metre from web, flange, and thickness dimensions. | Python |

## Usage

### Compress images and PDFs

Drop `Compress_PNG_JPG_PDF.bat` into a folder of photos/documents (or a parent folder) and run it. Results land in `Compressed/`, with subfolders mirrored. Tune `JPG_QUALITY`, `MAX_SIDE`, and `PDF_PROFILE` at the top of the file.

### Convert HEIC photos

Place `HEIC_to_JPG.bat` and `convert_HEIC_to_JPG.py` in the same folder as the photos, then run the batch file. JPGs go to `JPG/`.

```bat
pip install pillow pillow-heif
```

### Randomizers

Edit the `input_data` block at the top of `random2cols.py` or `random4cols.py`, then run:

```bat
python scripts\randomizers\random2cols.py
```

`Rina_m.py` is fully interactive and copies its output straight to the clipboard.

### AutoCAD

In AutoCAD, run `APPLOAD`, select the `.lsp` file, then invoke the command:

- `RANDTHK` — randomize selected thickness texts
- `RenumberSketches` — renumber selected sketch labels

### Angle weight calculator

```bat
python scripts\calculators\angle_calc.py
```

## Notes

- The copies here are portable: the HEIC batch file resolves its Python helper relative to its own location instead of a hard-coded Desktop path.
- Not included: `__pycache__` / `.pyc` files and the Windows/Office activation note (not appropriate for a public repository).
- Original files on the Desktop were left untouched.
