import csv

from django.db.models import Avg, Count, DurationField, ExpressionWrapper, F
from django.http import HttpResponse
from django.utils import timezone
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.complaints.models import Complaint


def _scoped_queryset(user):
    qs = Complaint.objects.all()
    if user.role == user.Role.DEPT_ADMIN:
        qs = qs.filter(department_id=user.department_id)
    return qs


class DashboardSummaryView(APIView):
    """
    Aggregated stats for the admin dashboard: totals by status/priority/
    issue type, and average resolution time. Citizens get stats scoped to
    their own complaints; department admins get stats scoped to their
    department; super admins see everything.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        qs = _scoped_queryset(user) if user.role != user.Role.CITIZEN else user.complaints.all()

        by_status = qs.values("status").annotate(count=Count("id"))
        by_priority = qs.values("priority").annotate(count=Count("id"))
        by_issue_type = qs.values("issue_type").annotate(count=Count("id"))
        by_department = (
            qs.values("department__name").annotate(count=Count("id"))
            if user.role != user.Role.CITIZEN
            else []
        )

        resolved = qs.filter(status=Complaint.Status.RESOLVED, resolved_at__isnull=False)
        avg_resolution_hours = None
        if resolved.exists():
            duration_expr = ExpressionWrapper(
                F("resolved_at") - F("created_at"), output_field=DurationField()
            )
            avg_duration = resolved.annotate(duration=duration_expr).aggregate(avg=Avg("duration"))["avg"]
            if avg_duration:
                avg_resolution_hours = round(avg_duration.total_seconds() / 3600, 1)

        return Response({
            "generated_at": timezone.now(),
            "total_complaints": qs.count(),
            "by_status": {row["status"]: row["count"] for row in by_status},
            "by_priority": {row["priority"]: row["count"] for row in by_priority},
            "by_issue_type": {row["issue_type"]: row["count"] for row in by_issue_type},
            "by_department": {row["department__name"] or "Unassigned": row["count"] for row in by_department},
            "avg_resolution_hours": avg_resolution_hours,
        })


class ExportReportCSVView(APIView):
    """Automated report generation -- downloads a CSV of scoped complaints."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        qs = _scoped_queryset(user) if user.role != user.Role.CITIZEN else user.complaints.all()

        response = HttpResponse(content_type="text/csv")
        response["Content-Disposition"] = 'attachment; filename="civic_issue_report.csv"'

        writer = csv.writer(response)
        writer.writerow([
            "ID", "Issue Type", "Priority", "Status", "Department",
            "Latitude", "Longitude", "Citizen", "Created At", "Resolved At",
        ])
        for c in qs.select_related("department", "citizen"):
            writer.writerow([
                c.id, c.issue_type, c.priority, c.status,
                c.department.name if c.department else "",
                c.latitude, c.longitude,
                c.citizen.full_name, c.created_at, c.resolved_at or "",
            ])
        return response
