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


def _list_ids(response):
    payload = response.json()
    results = payload["results"] if isinstance(payload, dict) else payload
    return {row["id"] for row in results}


class ComplaintAuthorizationTests(APITestCase):
    """Dept/citizen/super-admin isolation for list, detail, history, and status."""

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
            username="owner@civic.test",
            email="owner@civic.test",
            password="CivicTestPass123",
            phone_number="9111100101",
            full_name="Owner Citizen",
            role=User.Role.CITIZEN,
        )
        self.other_citizen = User.objects.create_user(
            username="other@civic.test",
            email="other@civic.test",
            password="CivicTestPass123",
            phone_number="9111100102",
            full_name="Other Citizen",
            role=User.Role.CITIZEN,
        )
        self.garbage_admin = User.objects.create_user(
            username="garbage.admin@civic.test",
            email="garbage.admin@civic.test",
            password="CivicTestPass123",
            phone_number="9111100103",
            full_name="Garbage Admin",
            role=User.Role.DEPT_ADMIN,
            department=self.dept_garbage,
        )
        self.water_admin = User.objects.create_user(
            username="water.admin@civic.test",
            email="water.admin@civic.test",
            password="CivicTestPass123",
            phone_number="9111100104",
            full_name="Water Admin",
            role=User.Role.DEPT_ADMIN,
            department=self.dept_water,
        )
        self.electrical_admin = User.objects.create_user(
            username="electrical.admin@civic.test",
            email="electrical.admin@civic.test",
            password="CivicTestPass123",
            phone_number="9111100105",
            full_name="Electrical Admin",
            role=User.Role.DEPT_ADMIN,
            department=self.dept_electrical,
        )
        self.super_admin = User.objects.create_user(
            username="super@civic.test",
            email="super@civic.test",
            password="CivicTestPass123",
            phone_number="9111100106",
            full_name="Super Admin",
            role=User.Role.SUPER_ADMIN,
        )

        self.garbage_complaint = self._make_complaint(
            "garbage.jpg",
            citizen=self.citizen,
            issue_type=Complaint.IssueType.GARBAGE,
            department=self.dept_garbage,
            description="Pile of garbage near the park",
        )
        self.water_complaint = self._make_complaint(
            "water.jpg",
            citizen=self.other_citizen,
            issue_type=Complaint.IssueType.WATER_LEAKAGE,
            department=self.dept_water,
            description="Burst water pipeline on MG Road",
        )
        self.electrical_complaint = self._make_complaint(
            "electrical.jpg",
            citizen=self.other_citizen,
            issue_type=Complaint.IssueType.STREETLIGHT,
            department=self.dept_electrical,
            description="Streetlight out on first cross",
        )

    def _make_complaint(self, filename, *, citizen, issue_type, department, description):
        return Complaint.objects.create(
            citizen=citizen,
            image=_tiny_jpeg(filename),
            description=description,
            latitude="12.971600",
            longitude="77.594600",
            address_text="Mysuru",
            issue_type=issue_type,
            classification_confidence=0.91,
            priority=Complaint.Priority.HIGH,
            status=Complaint.Status.REPORTED,
            department=department,
        )

    def _as(self, user):
        self.client.force_authenticate(user=user)

    def test_garbage_admin_sees_only_garbage_complaints(self):
        self._as(self.garbage_admin)
        response = self.client.get(COMPLAINTS_URL)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = _list_ids(response)
        self.assertEqual(ids, {self.garbage_complaint.id})
        self.assertNotIn(self.water_complaint.id, ids)
        self.assertNotIn(self.electrical_complaint.id, ids)

    def test_water_admin_does_not_see_garbage_complaints(self):
        self._as(self.water_admin)
        ids = _list_ids(self.client.get(COMPLAINTS_URL))
        self.assertEqual(ids, {self.water_complaint.id})
        self.assertNotIn(self.garbage_complaint.id, ids)

    def test_electrical_admin_does_not_see_garbage_complaints(self):
        self._as(self.electrical_admin)
        ids = _list_ids(self.client.get(COMPLAINTS_URL))
        self.assertEqual(ids, {self.electrical_complaint.id})
        self.assertNotIn(self.garbage_complaint.id, ids)

    def test_garbage_admin_cannot_bypass_with_department_or_search_or_ordering(self):
        self._as(self.garbage_admin)
        scoped = [
            f"{COMPLAINTS_URL}?department={self.dept_water.id}",
            f"{COMPLAINTS_URL}?department={self.dept_electrical.id}",
            f"{COMPLAINTS_URL}?ordering=created_at",
            f"{COMPLAINTS_URL}?ordering=-created_at",
            f"{COMPLAINTS_URL}?page=1",
        ]
        for url in scoped:
            with self.subTest(url=url):
                response = self.client.get(url)
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                ids = _list_ids(response)
                self.assertEqual(ids, {self.garbage_complaint.id})
                self.assertNotIn(self.water_complaint.id, ids)
                self.assertNotIn(self.electrical_complaint.id, ids)

        hidden = [
            f"{COMPLAINTS_URL}?search=water",
            f"{COMPLAINTS_URL}?search={self.water_complaint.id}",
            f"{COMPLAINTS_URL}?search=Burst",
        ]
        for url in hidden:
            with self.subTest(url=url):
                response = self.client.get(url)
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                ids = _list_ids(response)
                self.assertNotIn(self.water_complaint.id, ids)
                self.assertNotIn(self.electrical_complaint.id, ids)

    def test_garbage_admin_cannot_retrieve_foreign_detail_or_history(self):
        self._as(self.garbage_admin)
        for complaint in (self.water_complaint, self.electrical_complaint):
            with self.subTest(complaint_id=complaint.id):
                detail = self.client.get(f"{COMPLAINTS_URL}{complaint.id}/")
                history = self.client.get(f"{COMPLAINTS_URL}{complaint.id}/history/")
                self.assertEqual(detail.status_code, status.HTTP_404_NOT_FOUND)
                self.assertEqual(history.status_code, status.HTTP_404_NOT_FOUND)

    def test_garbage_admin_cannot_patch_foreign_status(self):
        self._as(self.garbage_admin)
        response = self.client.patch(
            f"{COMPLAINTS_URL}{self.water_complaint.id}/status/",
            {"status": "in_progress", "note": "should not work"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.water_complaint.refresh_from_db()
        self.assertEqual(self.water_complaint.status, Complaint.Status.REPORTED)

    def test_garbage_admin_can_patch_own_department_status(self):
        self._as(self.garbage_admin)
        response = self.client.patch(
            f"{COMPLAINTS_URL}{self.garbage_complaint.id}/status/",
            {"status": "in_progress", "note": "Crew assigned"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.garbage_complaint.refresh_from_db()
        self.assertEqual(self.garbage_complaint.status, Complaint.Status.IN_PROGRESS)
        self.assertEqual(self.garbage_complaint.status_logs.count(), 1)

    def test_super_admin_sees_all_and_can_filter_department(self):
        self._as(self.super_admin)
        all_ids = _list_ids(self.client.get(COMPLAINTS_URL))
        self.assertEqual(
            all_ids,
            {self.garbage_complaint.id, self.water_complaint.id, self.electrical_complaint.id},
        )
        water_only = _list_ids(self.client.get(f"{COMPLAINTS_URL}?department={self.dept_water.id}"))
        self.assertEqual(water_only, {self.water_complaint.id})

    def test_citizen_sees_only_own_complaints(self):
        self._as(self.citizen)
        ids = _list_ids(self.client.get(COMPLAINTS_URL))
        self.assertEqual(ids, {self.garbage_complaint.id})
        self.assertNotIn(self.water_complaint.id, ids)

    def test_citizen_cannot_retrieve_or_history_another_citizen_complaint(self):
        self._as(self.citizen)
        detail = self.client.get(f"{COMPLAINTS_URL}{self.water_complaint.id}/")
        history = self.client.get(f"{COMPLAINTS_URL}{self.water_complaint.id}/history/")
        self.assertEqual(detail.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(history.status_code, status.HTTP_404_NOT_FOUND)

    def test_garbage_admin_pagination_stays_in_department(self):
        for i in range(21):
            self._make_complaint(
                f"garbage-page-{i}.jpg",
                citizen=self.citizen,
                issue_type=Complaint.IssueType.GARBAGE,
                department=self.dept_garbage,
                description=f"Extra garbage {i}",
            )
        self._as(self.garbage_admin)
        page2 = self.client.get(f"{COMPLAINTS_URL}?page=2")
        self.assertEqual(page2.status_code, status.HTTP_200_OK)
        ids = _list_ids(page2)
        self.assertTrue(ids)
        self.assertNotIn(self.water_complaint.id, ids)
        self.assertNotIn(self.electrical_complaint.id, ids)
        self.assertTrue(all(
            Complaint.objects.get(pk=pk).department_id == self.dept_garbage.id for pk in ids
        ))

