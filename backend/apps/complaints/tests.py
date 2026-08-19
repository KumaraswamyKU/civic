"""
Phase 10 integration tests: complaint create API with mocked ML inference.

TensorFlow is not loaded; classify_image is patched on the views module
where it is imported.
"""
from io import BytesIO
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from PIL import Image
from rest_framework import status
from rest_framework.test import APITestCase

from apps.complaints.models import Complaint
from apps.departments.models import Department

User = get_user_model()

COMPLAINTS_URL = "/api/complaints/"


def _tiny_jpeg(name="test.jpg"):
    buffer = BytesIO()
    Image.new("RGB", (8, 8), color=(120, 120, 120)).save(buffer, format="JPEG")
    return SimpleUploadedFile(name, buffer.getvalue(), content_type="image/jpeg")


class ComplaintCreateMLIntegrationTests(APITestCase):
    def setUp(self):
        self.dept_garbage = Department.objects.create(
            code=Department.Code.GARBAGE,
            name="Waste Management Department",
        )
        self.dept_electrical = Department.objects.create(
            code=Department.Code.ELECTRICAL,
            name="Electrical Department",
        )
        self.dept_water = Department.objects.create(
            code=Department.Code.WATER,
            name="Water Supply Department",
        )

        self.citizen = User.objects.create_user(
            username="citizen@civic.test",
            email="citizen@civic.test",
            password="CivicTestPass123",
            phone_number="9111100001",
            full_name="Test Citizen",
            role=User.Role.CITIZEN,
        )
        self.client.force_authenticate(user=self.citizen)

    def _post_complaint(self, filename="complaint.jpg"):
        payload = {
            "image": _tiny_jpeg(filename),
            "description": "",
            "latitude": "12.971600",
            "longitude": "77.594600",
            "address_text": "",
        }
        return self.client.post(COMPLAINTS_URL, payload, format="multipart")

    def _assert_persisted(self, complaint_id):
        self.assertTrue(Complaint.objects.filter(pk=complaint_id).exists())
        return Complaint.objects.get(pk=complaint_id)

    @patch("apps.complaints.views.classify_image", return_value=("garbage", 0.90))
    def test_create_complaint_garbage_high_priority(self, _mock_classify):
        response = self._post_complaint("garbage.jpg")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        complaint = self._assert_persisted(response.data["id"])
        self.assertEqual(complaint.citizen_id, self.citizen.id)
        self.assertEqual(complaint.issue_type, Complaint.IssueType.GARBAGE)
        self.assertAlmostEqual(complaint.classification_confidence, 0.90)
        self.assertEqual(complaint.priority, Complaint.Priority.HIGH)
        self.assertEqual(complaint.department_id, self.dept_garbage.id)
        self.assertEqual(complaint.department.code, Department.Code.GARBAGE)

    @patch("apps.complaints.views.classify_image", return_value=("streetlight", 0.70))
    def test_create_complaint_streetlight_medium_priority(self, _mock_classify):
        response = self._post_complaint("streetlight.jpg")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        complaint = self._assert_persisted(response.data["id"])
        self.assertEqual(complaint.issue_type, Complaint.IssueType.STREETLIGHT)
        self.assertAlmostEqual(complaint.classification_confidence, 0.70)
        self.assertEqual(complaint.priority, Complaint.Priority.MEDIUM)
        self.assertEqual(complaint.department_id, self.dept_electrical.id)
        self.assertEqual(complaint.department.code, Department.Code.ELECTRICAL)

    @patch("apps.complaints.views.classify_image", return_value=("unknown", None))
    def test_create_complaint_unknown_unassigned_department(self, _mock_classify):
        response = self._post_complaint("unknown.jpg")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        complaint = self._assert_persisted(response.data["id"])
        self.assertEqual(complaint.issue_type, Complaint.IssueType.UNKNOWN)
        self.assertIsNone(complaint.classification_confidence)
        self.assertEqual(complaint.priority, Complaint.Priority.MEDIUM)
        self.assertIsNone(complaint.department)
        self.assertEqual(Complaint.objects.count(), 1)
