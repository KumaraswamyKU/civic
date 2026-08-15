# ML model weights

After running `python -m apps.ml.train` (see apps/ml/train.py), the
fine-tuned model is saved here as `civic_issue_model.h5`.

Until that file exists, `apps/ml/inference.py` runs in a safe fallback
mode: complaints are still created normally but tagged `issue_type =
"unknown"` with no confidence score. As soon as you drop a trained
`civic_issue_model.h5` in this folder, classification switches on
automatically -- no code changes needed.
