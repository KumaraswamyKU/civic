"""
Prepare CIVIC's streetlight training images from a local photo folder.

Reads JPG/PNG files from SOURCE (default: the Street _light download),
then copies them into:

  backend/dataset/train/streetlight/
  backend/dataset/val/streetlight/

80/20 train/validation split with a fixed random seed. Source files are
only copied, never modified or deleted.

Usage:
  python prepare_streetlight_dataset.py
  python prepare_streetlight_dataset.py --source "C:\\Users\\ks498\\Downloads\\Street _light"
"""
from __future__ import annotations

import argparse
import os
import random
import shutil
import sys
from pathlib import Path

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}
TRAIN_RATIO = 0.80
RANDOM_SEED = 42

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_SOURCE = Path(r"C:\Users\ks498\Downloads\Street _light")
DEFAULT_OUTPUT = SCRIPT_DIR / "backend" / "dataset"


def collect_images(source: Path) -> list[Path]:
    images: list[Path] = []
    for dirpath, _dirnames, filenames in os.walk(source):
        folder = Path(dirpath)
        for filename in filenames:
            path = folder / filename
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS:
                images.append(path)
    # Preserve a stable unique list if the same path appears twice.
    return list(dict.fromkeys(images))


def copy_split(files: list[Path], train_dir: Path, val_dir: Path, seed: int) -> tuple[int, int]:
    train_dir.mkdir(parents=True, exist_ok=True)
    val_dir.mkdir(parents=True, exist_ok=True)

    rng = random.Random(seed)
    shuffled = list(files)
    rng.shuffle(shuffled)

    split_at = int(round(len(shuffled) * TRAIN_RATIO))
    if len(shuffled) >= 2 and split_at >= len(shuffled):
        split_at = len(shuffled) - 1
    if len(shuffled) >= 2 and split_at == 0:
        split_at = 1

    train_files = shuffled[:split_at]
    val_files = shuffled[split_at:]

    for index, src in enumerate(train_files):
        dest_name = f"streetlight_{index:04d}{src.suffix.lower()}"
        shutil.copy2(src, train_dir / dest_name)

    for index, src in enumerate(val_files):
        dest_name = f"streetlight_{index:04d}{src.suffix.lower()}"
        shutil.copy2(src, val_dir / dest_name)

    return len(train_files), len(val_files)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Copy streetlight JPG/PNG images into CIVIC train/val folders (80/20)."
    )
    parser.add_argument(
        "--source",
        type=Path,
        default=DEFAULT_SOURCE,
        help=f"Folder of streetlight photos (default: {DEFAULT_SOURCE})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="CIVIC dataset root (default: backend/dataset next to this script).",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=RANDOM_SEED,
        help=f"Shuffle seed (default: {RANDOM_SEED}).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source = args.source.expanduser().resolve()
    output = args.output.expanduser().resolve()

    if not source.is_dir():
        print(f"Source folder not found: {source}", file=sys.stderr)
        print("Pass --source as the folder that contains the streetlight JPG/PNG files.", file=sys.stderr)
        return 1

    images = collect_images(source)
    print(f"Source: {source}")
    print(f"Output: {output}")
    print(f"JPG/PNG images found: {len(images)}")

    if len(images) < 2:
        print("Need at least 2 images to create an 80/20 train/val split.", file=sys.stderr)
        return 1

    train_dir = output / "train" / "streetlight"
    val_dir = output / "val" / "streetlight"
    n_train, n_val = copy_split(images, train_dir, val_dir, args.seed)

    print(f"Copied {n_train} -> {train_dir}")
    print(f"Copied {n_val}  -> {val_dir}")
    print("Source images were copied only; originals were not modified.")
    print("Done. garbage and water_leakage folders are unchanged.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
