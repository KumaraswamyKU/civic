# Dataset folder

Place your Kaggle dataset here, arranged like this before running
`apps/ml/train.py`:

```
dataset/
  train/
    garbage/
      img001.jpg
      img002.jpg
      ...
    streetlight/
      ...
    water_leakage/
      ...
  val/
    garbage/
    streetlight/
    water_leakage/
```

Folder names must exactly match `settings.ML_CLASS_NAMES` (`garbage`,
`streetlight`, `water_leakage`). An 80/20 or 85/15 train/val split per
class is a reasonable starting point.

This folder is intentionally left out of version control (see
`.gitignore`) since datasets shouldn't live in git -- only the folder
structure is tracked via this README and a `.gitkeep`.
