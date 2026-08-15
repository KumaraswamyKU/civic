"""
Prepare CIVIC's garbage training images from a downloaded waste-classification
dataset.

Reads waste-category folders from SOURCE, keeps only:
  trash, plastic, cardboard, glass, metal, paper, biological
then copies a balanced subset into:

  backend/dataset/train/garbage/
  backend/dataset/val/garbage/

80/20 train/validation split. Does not change train.py or the 3-class CIVIC
model — all selected waste types become the single class "garbage".

Usage:
  python prepare_garbage_dataset.py --source "C:\\path\\to\\downloaded\\dataset"
"""
from __future__ import annotations

import argparse
import os
import random
import shutil
import sys
from collections import defaultdict
from pathlib import Path

# Categories used for CIVIC garbage. Folder names are matched case-insensitively.
ALLOWED_CATEGORIES = (
    "trash",
    "plastic",
    "cardboard",
    "glass",
    "metal",
    "paper",
    "biological",
)

# Common Kaggle folder aliases → one of ALLOWED_CATEGORIES. Anything else is skipped.
FOLDER_ALIASES = {
    "trash": "trash",
    "plastic": "plastic",
    "cardboard": "cardboard",
    "glass": "glass",
    "metal": "metal",
    "paper": "paper",
    "biological": "biological",
    "organic": "biological",
    "organics": "biological",
    "bio": "biological",
    "green-glass": "glass",
    "white-glass": "glass",
    "brown-glass": "glass",
    "green_glass": "glass",
    "white_glass": "glass",
    "brown_glass": "glass",
    "greenglass": "glass",
    "whiteglass": "glass",
    "brownglass": "glass",
}

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp", ".gif"}

# Cap per waste category so one huge folder cannot explode the CIVIC garbage class.
# Actual count is min(this cap, smallest category size) so the set stays balanced.
MAX_IMAGES_PER_CATEGORY = 400
TRAIN_RATIO = 0.80
RANDOM_SEED = 42

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_OUTPUT = SCRIPT_DIR / "backend" / "dataset"


def normalize_folder_name(name: str) -> str:
    return name.strip().lower().replace(" ", "-")


def category_for_folder(folder_name: str) -> str | None:
    key = normalize_folder_name(folder_name)
    mapped = FOLDER_ALIASES.get(key)
    if mapped in ALLOWED_CATEGORIES:
        return mapped
    return None


def is_image(path: Path) -> bool:
    return path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS


def collect_images_by_category(source: Path) -> dict[str, list[Path]]:
    """
    Walk SOURCE and group image files by allowed waste category.

    A directory named like an allowed category (or alias) contributes every
    image in that directory (not nested class folders). This supports both:

      source/cardboard/*.jpg
      source/garbage classification/cardboard/*.jpg
      source/train/cardboard/*.jpg
    """
    grouped: dict[str, list[Path]] = defaultdict(list)

    for dirpath, _dirnames, filenames in os.walk(source):
        folder = Path(dirpath)
        category = category_for_folder(folder.name)
        if category is None:
            continue
        for filename in filenames:
            file_path = folder / filename
            if is_image(file_path):
                grouped[category].append(file_path)

    # Deduplicate if the same file is found twice (e.g. overlapping walks).
    for category, paths in grouped.items():
        unique = list(dict.fromkeys(paths))
        grouped[category] = unique

    return dict(grouped)


def balanced_count(grouped: dict[str, list[Path]]) -> int:
    sizes = [len(paths) for paths in grouped.values() if paths]
    if not sizes:
        return 0
    return min(MAX_IMAGES_PER_CATEGORY, min(sizes))


def copy_split(
    selected: dict[str, list[Path]],
    train_dir: Path,
    val_dir: Path,
    per_category: int,
) -> tuple[int, int]:
    train_dir.mkdir(parents=True, exist_ok=True)
    val_dir.mkdir(parents=True, exist_ok=True)

    n_train = 0
    n_val = 0
    rng = random.Random(RANDOM_SEED)

    for category, paths in sorted(selected.items()):
        files = list(paths)
        rng.shuffle(files)
        files = files[:per_category]
        split_at = int(round(len(files) * TRAIN_RATIO))
        # Keep at least one val image when the category has 2+ samples.
        if len(files) >= 2 and split_at >= len(files):
            split_at = len(files) - 1
        if len(files) >= 2 and split_at == 0:
            split_at = 1

        train_files = files[:split_at]
        val_files = files[split_at:]

        for index, src in enumerate(train_files):
            dest_name = f"{category}_{index:04d}{src.suffix.lower()}"
            shutil.copy2(src, train_dir / dest_name)
            n_train += 1

        for index, src in enumerate(val_files):
            dest_name = f"{category}_{index:04d}{src.suffix.lower()}"
            shutil.copy2(src, val_dir / dest_name)
            n_val += 1

    return n_train, n_val


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Build a balanced CIVIC garbage class from waste-category folders "
            "(trash, plastic, cardboard, glass, metal, paper, biological)."
        )
    )
    parser.add_argument(
        "--source",
        required=True,
        type=Path,
        help=(
            "Path to the downloaded waste dataset root (the folder that contains "
            "or nests the category folders: trash, plastic, cardboard, etc.)."
        ),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="CIVIC dataset root (default: backend/dataset next to this script).",
    )
    parser.add_argument(
        "--max-per-category",
        type=int,
        default=MAX_IMAGES_PER_CATEGORY,
        help=f"Upper cap per waste category (default: {MAX_IMAGES_PER_CATEGORY}).",
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
    global MAX_IMAGES_PER_CATEGORY, RANDOM_SEED
    MAX_IMAGES_PER_CATEGORY = args.max_per_category
    RANDOM_SEED = args.seed

    source = args.source.expanduser().resolve()
    output = args.output.expanduser().resolve()

    if not source.is_dir():
        print(f"Source folder not found: {source}", file=sys.stderr)
        print(
            "Pass --source as the folder that contains the waste-category "
            "directories (trash, plastic, cardboard, glass, metal, paper, biological).",
            file=sys.stderr,
        )
        return 1

    grouped = collect_images_by_category(source)

    print(f"Source: {source}")
    print(f"Output: {output}")
    print("Images found per allowed category:")
    for category in ALLOWED_CATEGORIES:
        count = len(grouped.get(category, []))
        status = "OK" if count else "MISSING"
        print(f"  {category:12} {count:5}  [{status}]")

    present = {k: v for k, v in grouped.items() if v}
    missing = [c for c in ALLOWED_CATEGORIES if c not in present]
    if missing:
        print(f"\nWarning: no images for: {', '.join(missing)}")
        print("Those categories will be skipped. Remaining categories stay balanced.")

    if not present:
        print(
            "\nNo allowed category folders were found under --source.\n"
            "Point --source at the downloaded dataset root so that folders named\n"
            "trash, plastic, cardboard, glass, metal, paper, and/or biological exist\n"
            "somewhere inside it.",
            file=sys.stderr,
        )
        return 1

    per_category = balanced_count(present)
    if per_category < 2:
        print(
            f"Not enough images to split 80/20 (balanced count={per_category}).",
            file=sys.stderr,
        )
        return 1

    train_dir = output / "train" / "garbage"
    val_dir = output / "val" / "garbage"

    n_train, n_val = copy_split(present, train_dir, val_dir, per_category)

    print(f"\nBalanced take: {per_category} images × {len(present)} categories")
    print(f"Copied {n_train} -> {train_dir}")
    print(f"Copied {n_val}  -> {val_dir}")
    print("Done. streetlight and water_leakage folders are unchanged.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
