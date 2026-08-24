import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:civic_mobile/main.dart';
import 'package:civic_mobile/providers/auth_provider.dart';
import 'package:civic_mobile/services/app_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Start screen confirms the Flutter app is running', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(CivicApp(auth: AuthProvider(AppServices())));
    await tester.pump();

    expect(find.text('Civic'), findsWidgets);
    expect(find.textContaining('Report'), findsWidgets);
  });
}
