import os
import sys

import numpy as np
import tensorflow as tf

from apps.ml.train import build_model


IMG_SIZE = (224, 224)

CLASS_NAMES = [
    "garbage",
    "streetlight",
    "water_leakage",
]

BASE_DIR = os.path.join(
    os.path.dirname(__file__),
    "..",
    "..",
)

MODEL_PATH = os.path.join(
    BASE_DIR,
    "ml_models",
    "civic_issue_model.h5",
)


def predict_image(image_path):
    print("\n" + "=" * 60)
    print("CIVIC ISSUE IMAGE PREDICTION")
    print("=" * 60)

    if not os.path.isfile(image_path):
        raise SystemExit(f"Image not found: {image_path}")

    if not os.path.isfile(MODEL_PATH):
        raise SystemExit(f"Model not found: {MODEL_PATH}")

    print(f"\nImage: {image_path}")

    # Recreate the same architecture used during training
    model = build_model(num_classes=len(CLASS_NAMES))

    # Load trained weights
    model.load_weights(MODEL_PATH)

    print("Model loaded successfully.")

    # Load and preprocess image
    image = tf.keras.utils.load_img(
        image_path,
        target_size=IMG_SIZE,
    )

    image_array = tf.keras.utils.img_to_array(image)

    image_array = np.expand_dims(
        image_array,
        axis=0,
    )

    # Predict
    predictions = model.predict(
        image_array,
        verbose=0,
    )[0]

    predicted_index = int(np.argmax(predictions))
    predicted_class = CLASS_NAMES[predicted_index]
    confidence = float(predictions[predicted_index]) * 100

    print("\nPrediction:")
    print(f"  Issue      : {predicted_class}")
    print(f"  Confidence : {confidence:.2f}%")

    print("\nAll class probabilities:")

    for class_name, probability in zip(
        CLASS_NAMES,
        predictions,
    ):
        print(
            f"  {class_name:<15}: "
            f"{probability * 100:.2f}%"
        )

    print("=" * 60)


if __name__ == "__main__":

    if len(sys.argv) != 2:
        raise SystemExit(
            "Usage:\n"
            "python -m apps.ml.predict <image_path>"
        )

    predict_image(sys.argv[1])