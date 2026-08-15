class ApiConfig {
  // Android emulator -> host machine's localhost is 10.0.2.2.
  // Change to your LAN IP (e.g. http://192.168.1.5:8000) for a physical device,
  // or your deployed server URL in production.
  static const String baseUrl = 'http://10.0.2.2:8000';

  static const String signup = '$baseUrl/api/auth/signup/';
  static const String login = '$baseUrl/api/auth/login/';
  static const String me = '$baseUrl/api/auth/me/';
  static const String complaints = '$baseUrl/api/complaints/';
  static const String reportSummary = '$baseUrl/api/reports/summary/';
  static const String reportExportCsv = '$baseUrl/api/reports/export/csv/';
}
