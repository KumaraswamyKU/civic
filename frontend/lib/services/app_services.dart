import 'api_client.dart';
import 'auth_service.dart';
import 'complaint_service.dart';
import 'department_service.dart';
import 'report_service.dart';

class AppServices {
  AppServices() {
    client = ApiClient();
    auth = AuthService(client);
    complaints = ComplaintService(client);
    departments = DepartmentService(client);
    reports = ReportService(client);
  }

  late final ApiClient client;
  late final AuthService auth;
  late final ComplaintService complaints;
  late final DepartmentService departments;
  late final ReportService reports;
}
