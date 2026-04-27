import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openAppDatabaseConnectionImpl() {
  return driftDatabase(name: 'couples_local_db');
}
