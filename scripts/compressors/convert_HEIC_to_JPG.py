import os
import sys
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

from PIL import Image
from pillow_heif import register_heif_opener

register_heif_opener()


def convert_one(job):
    src, dst = job
    try:
        with Image.open(src) as image:
            image.convert("RGB").save(dst, "JPEG", quality=75)
        return src, True, ""
    except Exception as exc:
        return src, False, str(exc)


def main():
    start_time = time.perf_counter()

    # Folder to read from (default: "heic_files" next to where you run this)
    if len(sys.argv) > 1:
        input_folder = Path(sys.argv[1]).expanduser().resolve()
    else:
        input_folder = Path("heic_files").resolve()

    # Folder to write to (default: "jpg_files" next to the input folder)
    if len(sys.argv) > 2:
        output_folder = Path(sys.argv[2]).expanduser().resolve()
    else:
        output_folder = input_folder.parent / "jpg_files"

    if not input_folder.is_dir():
        print(f"ERROR: input folder not found: {input_folder}")
        return 1

    output_folder.mkdir(parents=True, exist_ok=True)

    files = sorted(
        p for p in input_folder.iterdir()
        if p.is_file() and p.suffix.lower() in {".heic", ".heif"}
    )

    print(f"Input:  {input_folder}")
    print(f"Output: {output_folder}")

    if not files:
        print("No HEIC files found.")
        return 0

    jobs = []
    skipped = 0
    for src in files:
        dst = output_folder / (src.stem + ".jpg")
        # Skip files that were already converted after the source was last changed
        if dst.exists() and dst.stat().st_mtime >= src.stat().st_mtime:
            skipped += 1
            continue
        jobs.append((str(src), str(dst)))

    print(f"Found {len(files)} HEIC file(s): {len(jobs)} to convert, {skipped} already done.")
    print()

    if not jobs:
        print("Nothing to do.")
        return 0

    workers = max(1, min(os.cpu_count() or 1, len(jobs), 8))
    converted = 0
    failed = 0

    try:
        with ProcessPoolExecutor(max_workers=workers) as pool:
            futures = [pool.submit(convert_one, job) for job in jobs]
            for future in as_completed(futures):
                src, ok, error = future.result()
                name = os.path.basename(src)
                if ok:
                    converted += 1
                    print(f"Converted: {name}")
                else:
                    failed += 1
                    print(f"FAILED: {name} - {error}")
    except (OSError, PermissionError):
        # Fallback: convert one at a time if multiprocessing is not allowed
        print("Parallel mode unavailable, converting one by one...")
        for job in jobs:
            src, ok, error = convert_one(job)
            name = os.path.basename(src)
            if ok:
                converted += 1
                print(f"Converted: {name}")
            else:
                failed += 1
                print(f"FAILED: {name} - {error}")

    print()
    elapsed = time.perf_counter() - start_time
    print(f"Finished: {converted} converted, {failed} failed, {skipped} skipped in {elapsed:.1f}s.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
