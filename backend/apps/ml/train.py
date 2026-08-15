"""
Transfer-learning training script for the civic issue classifier.

HOW TO USE (after you've downloaded and placed your Kaggle dataset):
1. Arrange your dataset like this under backend/dataset/:

    dataset/
      train/
        garbage/          *.jpg
        streetlight/       *.jpg
        water_leakage/    *.jpg
      val/
        garbage/
        streetlight/
        water_leakage/

   (folder names must match settings.ML_CLASS_NAMES)

2. From inside the backend container (or a local venv with the
   requirements installed), run:

       python -m apps.ml.train

3. The fine-tuned model is written to ml_models/civic_issue_model.h5.
   apps/ml/inference.py picks it up automatically on the next request --
   no other code changes needed.

This uses MobileNetV2 pretrained on ImageNet as the frozen feature
extractor, with a small trainable classification head on top -- a good
default for a modest civic-issue image dataset and CPU-friendly training.
"""
import os
import random

import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 15
SEED = 42
CLASS_NAMES = ["garbage", "streetlight", "water_leakage"]
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".gif"}

DATASET_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "dataset")
TRAIN_DIR = os.path.join(DATASET_DIR, "train")
VAL_DIR = os.path.join(DATASET_DIR, "val")
OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "ml_models", "civic_issue_model.h5")


def set_seeds(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    tf.keras.utils.set_random_seed(seed)


def list_class_folders(root: str) -> list[str]:
    if not os.path.isdir(root):
        return []
    return sorted(
        name
        for name in os.listdir(root)
        if os.path.isdir(os.path.join(root, name)) and not name.startswith(".")
    )


def count_images(class_dir: str) -> int:
    if not os.path.isdir(class_dir):
        return 0
    return sum(
        1
        for name in os.listdir(class_dir)
        if os.path.isfile(os.path.join(class_dir, name))
        and os.path.splitext(name)[1].lower() in IMAGE_EXTENSIONS
    )


def validate_class_folders(split_dir: str, split_name: str) -> None:
    found = list_class_folders(split_dir)
    expected = CLASS_NAMES
    missing = [name for name in expected if name not in found]
    unexpected = [name for name in found if name not in expected]
    if missing or unexpected or found != expected:
        parts = [
            f"{split_name} class folders at {split_dir} do not match the required classes.",
            f"  required: {expected}",
            f"  found:    {found}",
        ]
        if missing:
            parts.append(f"  missing:  {missing}")
        if unexpected:
            parts.append(f"  unexpected: {unexpected}")
        raise SystemExit("\n".join(parts))


def compute_class_weights(train_dir: str) -> dict[int, float]:
    """Balanced weights: n_samples / (n_classes * n_samples_i), from train folder counts."""
    counts = [count_images(os.path.join(train_dir, name)) for name in CLASS_NAMES]
    empty = [name for name, n in zip(CLASS_NAMES, counts) if n == 0]
    if empty:
        raise SystemExit(f"No training images found for class(es): {empty}")

    n_samples = sum(counts)
    n_classes = len(CLASS_NAMES)
    weights = {
        index: n_samples / (n_classes * count)
        for index, count in enumerate(counts)
    }
    print("Training image counts:")
    for name, count in zip(CLASS_NAMES, counts):
        print(f"  {name}: {count}")
    print("Class weights:")
    for index, name in enumerate(CLASS_NAMES):
        print(f"  {name}: {weights[index]:.4f}")
    return weights


def build_augmentation() -> tf.keras.Sequential:
    return tf.keras.Sequential(
        [
            layers.RandomFlip("horizontal"),
            layers.RandomRotation(0.1),
            layers.RandomZoom(0.1),
            layers.RandomContrast(0.1),
        ],
        name="train_augmentation",
    )


def build_model(num_classes: int) -> tf.keras.Model:
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=IMG_SIZE + (3,), include_top=False, weights="imagenet"
    )
    base_model.trainable = False  # freeze the pretrained backbone

    inputs = tf.keras.Input(shape=IMG_SIZE + (3,))
    x = tf.keras.applications.mobilenet_v2.preprocess_input(inputs)
    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)

    model = models.Model(inputs, outputs)
    model.compile(optimizer="adam", loss="categorical_crossentropy", metrics=["accuracy"])
    return model


def main():
    set_seeds(SEED)

    if not os.path.isdir(TRAIN_DIR):
        raise SystemExit(
            f"Training data not found at {TRAIN_DIR}.\n"
            "Place your Kaggle dataset under backend/dataset/train/<class_name>/ "
            "and backend/dataset/val/<class_name>/ first -- see the docstring "
            "at the top of this file."
        )
    if not os.path.isdir(VAL_DIR):
        raise SystemExit(f"Validation data not found at {VAL_DIR}.")

    validate_class_folders(TRAIN_DIR, "train")
    validate_class_folders(VAL_DIR, "val")
    class_weight = compute_class_weights(TRAIN_DIR)

    train_ds = tf.keras.utils.image_dataset_from_directory(
        TRAIN_DIR,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        label_mode="categorical",
        shuffle=True,
        seed=SEED,
    )
    val_ds = tf.keras.utils.image_dataset_from_directory(
        VAL_DIR,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        label_mode="categorical",
        shuffle=False,
    )

    if train_ds.class_names != CLASS_NAMES:
        raise SystemExit(
            "Keras train class order does not match required classes.\n"
            f"  required: {CLASS_NAMES}\n"
            f"  keras:    {train_ds.class_names}"
        )
    if val_ds.class_names != CLASS_NAMES:
        raise SystemExit(
            "Keras val class order does not match required classes.\n"
            f"  required: {CLASS_NAMES}\n"
            f"  keras:    {val_ds.class_names}"
        )
    print(f"Detected classes (folder names): {train_ds.class_names}")

    augmentation = build_augmentation()
    train_ds = train_ds.map(
        lambda images, labels: (augmentation(images, training=True), labels),
        num_parallel_calls=tf.data.AUTOTUNE,
    )
    train_ds = train_ds.prefetch(tf.data.AUTOTUNE)
    val_ds = val_ds.prefetch(tf.data.AUTOTUNE)

    model = build_model(num_classes=len(CLASS_NAMES))

    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS,
        class_weight=class_weight,
    )

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    model.save(OUTPUT_PATH)
    print(f"Saved fine-tuned model to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
