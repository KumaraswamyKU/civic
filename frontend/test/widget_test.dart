import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:civic_issue_app/main.dart';
import 'package:civic_issue_app/providers/auth_controller.dart';
import 'package:civic_issue_app/services/app_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login screen shows Civic Operations Center', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(CivicOpsApp(auth: AuthController(AppServices())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('CIVIC'), findsWidgets);
    expect(find.textContaining('Operations'), findsWidgets);
  });
}
