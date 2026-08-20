import 'api_client.dart';
import 'auth_service.dart';
import 'complaint_service.dart';
import 'department_service.dart';
import 'image_pick_service.dart';
import 'location_service.dart';
import 'report_service.dart';
import 'token_storage.dart';

class AppServices {
  AppServices() {
    tokenStorage = TokenStorage();
    apiClient = ApiClient(tokenStorage: tokenStorage);
    auth = AuthService(apiClient);
    complaints = ComplaintService(apiClient);
    departments = DepartmentService(apiClient);
    reports = ReportService(apiClient);
    images = ImagePickService();
    location = LocationService();
  }

  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthService auth;
  late final ComplaintService complaints;
  late final DepartmentService departments;
  late final ReportService reports;
  late final ImagePickService images;
  late final LocationService location;
}
