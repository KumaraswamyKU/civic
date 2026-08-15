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

import tensorflow as tf
from tensorflow.keras import layers, models

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 15
CLASS_NAMES = ["garbage", "streetlight", "water_leakage"]

DATASET_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "dataset")
TRAIN_DIR = os.path.join(DATASET_DIR, "train")
VAL_DIR = os.path.join(DATASET_DIR, "val")
OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "ml_models", "civic_issue_model.h5")


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
    if not os.path.isdir(TRAIN_DIR):
        raise SystemExit(
            f"Training data not found at {TRAIN_DIR}.\n"
            "Place your Kaggle dataset under backend/dataset/train/<class_name>/ "
            "and backend/dataset/val/<class_name>/ first -- see the docstring "
            "at the top of this file."
        )

    train_ds = tf.keras.utils.image_dataset_from_directory(
        TRAIN_DIR, image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode="categorical"
    )
    val_ds = tf.keras.utils.image_dataset_from_directory(
        VAL_DIR, image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode="categorical"
    )

    detected_classes = train_ds.class_names
    print(f"Detected classes (folder names): {detected_classes}")
    if detected_classes != CLASS_NAMES:
        print(
            "WARNING: folder names/order don't match "
            f"{CLASS_NAMES}. Update settings.ML_CLASS_NAMES to match, or "
            "rename your dataset folders."
        )

    model = build_model(num_classes=len(detected_classes))

    model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS)

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    model.save(OUTPUT_PATH)
    print(f"Saved fine-tuned model to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
