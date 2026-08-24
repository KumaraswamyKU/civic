from rest_framework import serializers

from .models import Complaint, ComplaintStatusLog


class ComplaintCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Complaint
        fields = ["id", "image", "description", "latitude", "longitude", "address_text"]
        read_only_fields = ["id"]


class ComplaintSerializer(serializers.ModelSerializer):
    citizen_name = serializers.CharField(source="citizen.full_name", read_only=True)
    citizen_email = serializers.EmailField(source="citizen.email", read_only=True)
    department_name = serializers.CharField(source="department.name", read_only=True)

    class Meta:
        model = Complaint
        fields = [
            "id", "citizen", "citizen_name", "citizen_email", "image", "description",
            "latitude", "longitude", "address_text",
            "issue_type", "classification_confidence", "priority", "status",
            "department", "department_name",
            "created_at", "updated_at", "resolved_at",
        ]
        read_only_fields = [
            "citizen", "issue_type", "classification_confidence",
            "priority", "department", "created_at", "updated_at", "resolved_at",
        ]


class ComplaintStatusUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=Complaint.Status.choices)
    note = serializers.CharField(required=False, allow_blank=True)


class ComplaintStatusLogSerializer(serializers.ModelSerializer):
    changed_by_name = serializers.CharField(source="changed_by.full_name", read_only=True)

    class Meta:
        model = ComplaintStatusLog
        fields = ["id", "old_status", "new_status", "note", "changed_by_name", "changed_at"]
