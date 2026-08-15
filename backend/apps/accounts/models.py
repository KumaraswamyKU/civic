from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """
    Custom user model. Citizens sign up with name/email/phone/password.
    Department admins (garbage, water, electrical) are created by a
    superuser via /admin and are tied to a Department (see apps.departments).
    """

    class Role(models.TextChoices):
        CITIZEN = "citizen", "Citizen"
        DEPT_ADMIN = "dept_admin", "Department Admin"
        SUPER_ADMIN = "super_admin", "Super Admin"

    # username stays for Django compatibility, but login is via email or phone
    email = models.EmailField(unique=True)
    phone_number = models.CharField(max_length=15, unique=True)
    full_name = models.CharField(max_length=150)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.CITIZEN)
    department = models.ForeignKey(
        "departments.Department",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="admins",
        help_text="Set only for dept_admin users.",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username", "phone_number", "full_name"]

    def __str__(self):
        return f"{self.full_name} ({self.email})"
