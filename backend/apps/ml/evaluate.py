"""
Evaluate the trained Civic Issue classification model.

Evaluates the saved model against the validation dataset and reports:
- Accuracy
- Precision
- Recall
- F1-score
- Confusion matrix
"""

import os

import numpy as np
import tensorflow as tf
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
)

from apps.ml.train import build_model


IMG_SIZE = (224, 224)
BATCH_SIZE = 32

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

VAL_DIR = os.path.join(
    BASE_DIR,
    "dataset",
    "val",
)

MODEL_PATH = os.path.join(
    BASE_DIR,
    "ml_models",
    "civic_issue_model.h5",
)


def main():
    print("=" * 60)
    print("CIVIC ISSUE MODEL EVALUATION")
    print("=" * 60)

    # ---------------------------------------------------------
    # 1. Check paths
    # ---------------------------------------------------------

    if not os.path.isdir(VAL_DIR):
        raise SystemExit(
            f"Validation dataset not found: {VAL_DIR}"
        )

    if not os.path.isfile(MODEL_PATH):
        raise SystemExit(
            f"Trained model not found: {MODEL_PATH}"
        )

    print(f"\nValidation dataset: {VAL_DIR}")
    print(f"Model: {MODEL_PATH}")

    # ---------------------------------------------------------
    # 2. Load validation dataset
    # ---------------------------------------------------------

    print("\nLoading validation dataset...")

    val_ds = tf.keras.utils.image_dataset_from_directory(
        VAL_DIR,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        label_mode="categorical",
        shuffle=False,
    )

    print(
        f"\nDetected classes: {val_ds.class_names}"
    )

    # ---------------------------------------------------------
    # 3. Verify class order
    # ---------------------------------------------------------

    if val_ds.class_names != CLASS_NAMES:
        raise SystemExit(
            "Class order does not match expected classes.\n"
            f"Expected: {CLASS_NAMES}\n"
            f"Found:    {val_ds.class_names}"
        )

    # ---------------------------------------------------------
    # 4. Recreate architecture and load trained weights
    # ---------------------------------------------------------

    print(
        "\nRecreating trained model architecture..."
    )

    model = build_model(
        num_classes=len(CLASS_NAMES)
    )

    print(
        "Model architecture recreated successfully."
    )

    print("\nLoading trained weights...")

    try:
        model.load_weights(MODEL_PATH)
    except Exception as e:
        raise SystemExit(
            f"Could not load trained weights from "
            f"{MODEL_PATH}.\n"
            f"Error: {e}"
        )

    print(
        "Trained weights loaded successfully."
    )

    # ---------------------------------------------------------
    # 5. Generate predictions
    # ---------------------------------------------------------

    print("\nRunning predictions...")

    y_true = []
    y_pred = []

    for images, labels in val_ds:

        predictions = model.predict(
            images,
            verbose=0,
        )

        predicted_classes = np.argmax(
            predictions,
            axis=1,
        )

        actual_classes = np.argmax(
            labels.numpy(),
            axis=1,
        )

        y_pred.extend(predicted_classes)
        y_true.extend(actual_classes)

    y_true = np.array(y_true)
    y_pred = np.array(y_pred)

    # ---------------------------------------------------------
    # 6. Overall accuracy
    # ---------------------------------------------------------

    accuracy = accuracy_score(
        y_true,
        y_pred,
    )

    print("\n" + "=" * 60)
    print("OVERALL ACCURACY")
    print("=" * 60)

    print(
        f"Validation Accuracy: "
        f"{accuracy * 100:.2f}%"
    )

    # ---------------------------------------------------------
    # 7. Classification report
    # ---------------------------------------------------------

    print("\n" + "=" * 60)
    print("CLASSIFICATION REPORT")
    print("=" * 60)

    report = classification_report(
        y_true,
        y_pred,
        target_names=CLASS_NAMES,
        digits=4,
        zero_division=0,
    )

    print(report)

    # ---------------------------------------------------------
    # 8. Confusion matrix
    # ---------------------------------------------------------

    print("=" * 60)
    print("CONFUSION MATRIX")
    print("=" * 60)

    cm = confusion_matrix(
        y_true,
        y_pred,
    )

    print("\nRows = Actual")
    print("Columns = Predicted\n")

    print(
        " " * 20
        + "  ".join(
            f"{name:>15}"
            for name in CLASS_NAMES
        )
    )

    for i, class_name in enumerate(CLASS_NAMES):

        print(
            f"{class_name:>20}"
            + "  "
            + "  ".join(
                f"{value:>15}"
                for value in cm[i]
            )
        )

    # ---------------------------------------------------------
    # 9. Per-class summary
    # ---------------------------------------------------------

    print("\n" + "=" * 60)
    print("PER-CLASS RESULTS")
    print("=" * 60)

    report_dict = classification_report(
        y_true,
        y_pred,
        target_names=CLASS_NAMES,
        output_dict=True,
        zero_division=0,
    )

    for class_name in CLASS_NAMES:

        precision = report_dict[
            class_name
        ]["precision"]

        recall = report_dict[
            class_name
        ]["recall"]

        f1 = report_dict[
            class_name
        ]["f1-score"]

        support = int(
            report_dict[
                class_name
            ]["support"]
        )

        print(f"\n{class_name.upper()}")
        print(f"  Precision : {precision:.4f}")
        print(f"  Recall    : {recall:.4f}")
        print(f"  F1-score  : {f1:.4f}")
        print(f"  Support   : {support}")

    # ---------------------------------------------------------
    # 10. Completion
    # ---------------------------------------------------------

    print("\n" + "=" * 60)
    print("EVALUATION COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()