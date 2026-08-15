"""
Small rule-based helpers used until the CNN model is fine-tuned with a
dedicated severity output. These are intentionally simple and documented
so they're easy to replace once you train on your Kaggle dataset.
"""
from apps.departments.models import Department

from .models import Complaint

ISSUE_TYPE_TO_DEPARTMENT_CODE = {
    Complaint.IssueType.GARBAGE: Department.Code.GARBAGE,
    Complaint.IssueType.STREETLIGHT: Department.Code.ELECTRICAL,
    Complaint.IssueType.WATER_LEAKAGE: Department.Code.WATER,
}

# Keywords in the citizen's description that bump priority up. This is a
# placeholder heuristic -- once the CNN model is trained on the Kaggle
# dataset, replace/augment this with a proper severity-estimation output
# from the model itself.
HIGH_PRIORITY_KEYWORDS = [
    "overflow", "overflowing", "burst", "flooding", "sparking", "fire",
    "electrocution", "shock", "collapsed", "leak spraying", "major",
]
LOW_PRIORITY_KEYWORDS = ["minor", "small", "slight"]


def resolve_department_for_issue(issue_type: str):
    code = ISSUE_TYPE_TO_DEPARTMENT_CODE.get(issue_type)
    if not code:
        return None
    return Department.objects.filter(code=code).first()


def estimate_priority(issue_type: str, confidence: float, description: str) -> str:
    text = (description or "").lower()

    if any(word in text for word in HIGH_PRIORITY_KEYWORDS):
        return Complaint.Priority.HIGH
    if any(word in text for word in LOW_PRIORITY_KEYWORDS):
        return Complaint.Priority.LOW

    # Fall back to classification confidence: a very confident detection of
    # a real issue is treated as more urgent than an ambiguous one.
    if confidence is not None:
        if confidence >= 0.85:
            return Complaint.Priority.HIGH
        if confidence >= 0.6:
            return Complaint.Priority.MEDIUM
        return Complaint.Priority.LOW

    return Complaint.Priority.MEDIUM
