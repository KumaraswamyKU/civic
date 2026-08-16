"""
CNN inference wrapper for civic issue classification.

Uses the same MobileNetV2 architecture defined in train.py and loads
the trained weights from the saved H5 file.
"""

import logging
import os
import threading

from django.conf import settings

logger = logging.getLogger(__name__)

_model = None
_model_lock = threading.Lock()
_load_attempted = False


def _try_load_model():
    global _model, _load_attempted

    with _model_lock:
        if _load_attempted:
            return _model

        _load_attempted = True

        model_path = settings.ML_MODEL_PATH

        if not os.path.exists(model_path):
            logger.warning(
                "No trained model found at %s. "
                "Running in fallback mode.",
                model_path,
            )
            return None

        try:
            from apps.ml.train import build_model

            import tensorflow as tf

            # Recreate the exact architecture used during training.
            _model = build_model(
                num_classes=len(settings.ML_CLASS_NAMES)
            )

            # Load only the learned weights.
            _model.load_weights(model_path)

            logger.info(
                "Loaded civic issue model weights from %s",
                model_path,
            )

        except Exception:
            logger.exception(
                "Failed to load ML model, "
                "falling back to unclassified mode."
            )
            _model = None

        return _model


def classify_image(image_path: str):
    """
    Returns:

        (issue_type, confidence)

    issue_type:
        garbage
        streetlight
        water_leakage
        unknown

    confidence:
        Float between 0 and 1, or None in fallback mode.
    """

    model = _try_load_model()

    if model is None:
        return "unknown", None

    try:
        import numpy as np
        from tensorflow.keras.preprocessing import image as keras_image

        img = keras_image.load_img(
            image_path,
            target_size=settings.ML_IMAGE_SIZE,
        )

        # Convert image to array.
        # Values remain in [0, 255].
        # MobileNetV2 preprocessing is already inside the model.
        arr = keras_image.img_to_array(img)

        arr = np.expand_dims(
            arr,
            axis=0,
        )

        predictions = model.predict(
            arr,
            verbose=0,
        )[0]

        best_idx = int(np.argmax(predictions))

        confidence = float(
            predictions[best_idx]
        )

        issue_type = settings.ML_CLASS_NAMES[
            best_idx
        ]

        return issue_type, confidence

    except Exception:
        logger.exception(
            "Inference failed for %s",
            image_path,
        )
        return "unknown", None