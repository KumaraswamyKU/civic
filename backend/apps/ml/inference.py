"""
CNN inference wrapper for civic issue classification.

Design: a MobileNetV2-based transfer-learning model with 3 output classes
(garbage, streetlight, water_leakage). Until you fine-tune it on your own
Kaggle dataset (see train.py) and drop the resulting .h5 file at
settings.ML_MODEL_PATH, this module runs in a safe FALLBACK mode so the
rest of the API keeps working end-to-end -- new complaints are still
created, just tagged as "unknown" with 0 confidence until you plug in a
real model, at which point classification kicks in automatically without
any other code changes.
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
                "No trained model found at %s. Running in fallback mode -- "
                "complaints will be saved as 'unknown' until you fine-tune "
                "and place civic_issue_model.h5 there (see apps/ml/train.py).",
                model_path,
            )
            return None

        try:
            import tensorflow as tf

            _model = tf.keras.models.load_model(model_path)
            logger.info("Loaded civic issue classification model from %s", model_path)
        except Exception:
            logger.exception("Failed to load ML model, falling back to unclassified mode.")
            _model = None

        return _model


def classify_image(image_path: str):
    """
    Returns (issue_type: str, confidence: float | None).
    issue_type is one of settings.ML_CLASS_NAMES, or "unknown" in fallback mode.
    """
    model = _try_load_model()
    if model is None:
        return "unknown", None

    try:
        import numpy as np
        from tensorflow.keras.preprocessing import image as keras_image

        img = keras_image.load_img(image_path, target_size=settings.ML_IMAGE_SIZE)
        # img_to_array is [0, 255], matching image_dataset_from_directory.
        # Do not divide by 255: the saved model already applies
        # mobilenet_v2.preprocess_input (expects [0, 255] → [-1, 1]).
        arr = keras_image.img_to_array(img)
        arr = np.expand_dims(arr, axis=0)

        predictions = model.predict(arr, verbose=0)[0]
        best_idx = int(predictions.argmax())
        confidence = float(predictions[best_idx])
        issue_type = settings.ML_CLASS_NAMES[best_idx]
        return issue_type, confidence
    except Exception:
        logger.exception("Inference failed for %s, falling back to unclassified.", image_path)
        return "unknown", None
