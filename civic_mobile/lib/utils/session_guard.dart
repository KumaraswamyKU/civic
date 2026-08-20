import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../utils/api_exception.dart';
import '../utils/app_routes.dart';
import '../utils/error_messages.dart';

Future<void> showAppError(BuildContext context, Object error) async {
  if (!context.mounted) {
    return;
  }
  if (error is ApiException && error.isUnauthorized) {
    await AuthScope.of(context).logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(userFacingError(error))),
  );
}
