import 'api_exception.dart';

String userFacingError(Object error) {
  if (error is ApiException) {
    if (error.isUnauthorized) {
      return 'Your session expired. Please sign in again.';
    }
    return error.message;
  }
  return error.toString();
}
