from rest_framework import permissions


class IsCitizenOwnerOrDeptAdmin(permissions.BasePermission):
    """
    Citizens can only see/act on their own complaints.
    Department admins can only see/act on complaints routed to their department.
    Super admins can see everything.
    """

    def has_object_permission(self, request, view, obj):
        user = request.user
        if user.role == user.Role.SUPER_ADMIN:
            return True
        if user.role == user.Role.DEPT_ADMIN:
            return obj.department_id == user.department_id
        return obj.citizen_id == user.id
