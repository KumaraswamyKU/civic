from django.conf import settings
from django.db import models

from apps.departments.models import Department


def complaint_image_path(instance, filename):
    return f"complaints/{instance.citizen_id}/{filename}"


class Complaint(models.Model):
    class IssueType(models.TextChoices):
        GARBAGE = "garbage", "Garbage Accumulation"
        STREETLIGHT = "streetlight", "Faulty Streetlight"
        WATER_LEAKAGE = "water_leakage", "Water Leakage"
        UNKNOWN = "unknown", "Unclassified"

    class Priority(models.TextChoices):
        HIGH = "high", "High"
        MEDIUM = "medium", "Medium"
        LOW = "low", "Low"

    class Status(models.TextChoices):
        REPORTED = "reported", "Reported"
        IN_PROGRESS = "in_progress", "In Progress"
        RESOLVED = "resolved", "Resolved"
        REJECTED = "rejected", "Rejected"

    citizen = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="complaints"
    )
    image = models.ImageField(upload_to=complaint_image_path)
    description = models.TextField(blank=True)

    # GPS location, auto-captured on the client and sent with the upload
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    address_text = models.CharField(max_length=255, blank=True)

    issue_type = models.CharField(max_length=20, choices=IssueType.choices, default=IssueType.UNKNOWN)
    classification_confidence = models.FloatField(null=True, blank=True)

    priority = models.CharField(max_length=10, choices=Priority.choices, default=Priority.MEDIUM)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.REPORTED)

    department = models.ForeignKey(
        Department, on_delete=models.SET_NULL, null=True, blank=True, related_name="complaints"
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    resolved_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"#{self.id} {self.issue_type} ({self.priority}) - {self.status}"


class ComplaintStatusLog(models.Model):
    """Audit trail every time a department admin changes a complaint's status."""

    complaint = models.ForeignKey(Complaint, on_delete=models.CASCADE, related_name="status_logs")
    changed_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    old_status = models.CharField(max_length=20)
    new_status = models.CharField(max_length=20)
    note = models.CharField(max_length=255, blank=True)
    changed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-changed_at"]
