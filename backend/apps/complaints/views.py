from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.ml.inference import classify_image

from .models import Complaint, ComplaintStatusLog
from .permissions import IsCitizenOwnerOrDeptAdmin
from .serializers import (
    ComplaintCreateSerializer,
    ComplaintSerializer,
    ComplaintStatusLogSerializer,
    ComplaintStatusUpdateSerializer,
)
from .utils import estimate_priority, resolve_department_for_issue


class ComplaintViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsCitizenOwnerOrDeptAdmin]
    http_method_names = ["get", "post", "patch", "head", "options"]

    def get_serializer_class(self):
        if self.action == "create":
            return ComplaintCreateSerializer
        return ComplaintSerializer

    def get_queryset(self):
        user = self.request.user
        qs = Complaint.objects.select_related("department", "citizen")
        if user.role == user.Role.SUPER_ADMIN:
            return qs
        if user.role == user.Role.DEPT_ADMIN:
            return qs.filter(department_id=user.department_id)
        return qs.filter(citizen=user)

    def perform_create(self, serializer):
        complaint = serializer.save(citizen=self.request.user)

        # Run the CNN classifier (falls back gracefully if no trained
        # weights have been placed in ml_models/ yet -- see apps/ml/inference.py)
        issue_type, confidence = classify_image(complaint.image.path)

        complaint.issue_type = issue_type
        complaint.classification_confidence = confidence
        complaint.priority = estimate_priority(issue_type, confidence, complaint.description)
        complaint.department = resolve_department_for_issue(issue_type)
        complaint.save()

    @action(detail=True, methods=["patch"], url_path="status")
    def update_status(self, request, pk=None):
        complaint = self.get_object()
        serializer = ComplaintStatusUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        new_status = serializer.validated_data["status"]
        note = serializer.validated_data.get("note", "")

        ComplaintStatusLog.objects.create(
            complaint=complaint,
            changed_by=request.user,
            old_status=complaint.status,
            new_status=new_status,
            note=note,
        )

        complaint.status = new_status
        if new_status == Complaint.Status.RESOLVED:
            complaint.resolved_at = timezone.now()
        complaint.save()

        return Response(ComplaintSerializer(complaint).data)

    @action(detail=True, methods=["get"], url_path="history")
    def history(self, request, pk=None):
        complaint = self.get_object()
        logs = complaint.status_logs.all()
        return Response(ComplaintStatusLogSerializer(logs, many=True).data)
