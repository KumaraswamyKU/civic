from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from .models import User


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    list_display = ("email", "full_name", "phone_number", "role", "department", "is_active")
    list_filter = ("role", "department", "is_active")
    search_fields = ("email", "full_name", "phone_number")
    fieldsets = DjangoUserAdmin.fieldsets + (
        ("Civic system info", {"fields": ("full_name", "phone_number", "role", "department")}),
    )
    add_fieldsets = DjangoUserAdmin.add_fieldsets + (
        ("Civic system info", {"fields": ("full_name", "phone_number", "role", "department")}),
    )
