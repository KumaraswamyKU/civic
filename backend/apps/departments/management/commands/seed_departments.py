from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand

from apps.departments.models import Department

User = get_user_model()

# Default department admin credentials for first-time setup.
# CHANGE THESE PASSWORDS immediately after first login in production.
DEFAULT_ADMINS = [
    {
        "code": Department.Code.GARBAGE,
        "name": "Waste Management Department",
        "email": "garbage.admin@civicsystem.local",
        "phone_number": "9000000001",
        "full_name": "Garbage Department Admin",
        "password": "Garbage@123",
    },
    {
        "code": Department.Code.WATER,
        "name": "Water Supply Department",
        "email": "water.admin@civicsystem.local",
        "phone_number": "9000000002",
        "full_name": "Water Department Admin",
        "password": "Water@123",
    },
    {
        "code": Department.Code.ELECTRICAL,
        "name": "Electrical Department",
        "email": "electrical.admin@civicsystem.local",
        "phone_number": "9000000003",
        "full_name": "Electrical Department Admin",
        "password": "Electrical@123",
    },
]


class Command(BaseCommand):
    help = "Creates the 3 departments and one default admin user per department (idempotent)."

    def handle(self, *args, **options):
        for entry in DEFAULT_ADMINS:
            dept, created = Department.objects.get_or_create(
                code=entry["code"], defaults={"name": entry["name"]}
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f"Created department: {dept.name}"))

            if not User.objects.filter(email=entry["email"]).exists():
                user = User(
                    username=entry["email"],
                    email=entry["email"],
                    phone_number=entry["phone_number"],
                    full_name=entry["full_name"],
                    role=User.Role.DEPT_ADMIN,
                    department=dept,
                    is_staff=True,
                )
                user.set_password(entry["password"])
                user.save()
                self.stdout.write(
                    self.style.SUCCESS(f"Created admin {entry['email']} / {entry['password']}")
                )
            else:
                self.stdout.write(f"Admin {entry['email']} already exists, skipping.")
