from django.contrib import admin

from .models import Complaint, ComplaintStatusLog


@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = ("id", "issue_type", "priority", "status", "department", "citizen", "created_at")
    list_filter = ("issue_type", "priority", "status", "department")
    search_fields = ("description", "citizen__email", "citizen__full_name")


@admin.register(ComplaintStatusLog)
class ComplaintStatusLogAdmin(admin.ModelAdmin):
    list_display = ("complaint", "old_status", "new_status", "changed_by", "changed_at")
