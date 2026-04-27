import 'package:drift/drift.dart';

/// Fallback when neither `dart:html` nor `dart:io` is available.
QueryExecutor openAppDatabaseConnectionImpl() {
  throw UnsupportedError('Drift is only supported on io or web.');
}
