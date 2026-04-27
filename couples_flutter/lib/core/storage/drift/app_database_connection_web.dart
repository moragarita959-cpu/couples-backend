import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:web/web.dart';

/// Resolve wasm/worker URLs so they work when the app is opened on a route like `/bill`
/// (relative `sqlite3.wasm` would incorrectly resolve to `/bill/sqlite3.wasm`).
/// Also honors `<base href>` for `--base-href` deploys.
Uri _wasmAssetUri(String name) {
  final base = Uri.parse(document.baseURI);
  var path = base.path;
  if (path.isEmpty || path == '/') {
    return Uri.parse('${base.origin}/$name');
  }
  if (path.endsWith('/')) {
    return base.resolve(name);
  }
  final slash = path.lastIndexOf('/');
  if (slash <= 0) {
    return Uri.parse('${base.origin}/$name');
  }
  final parent = base.replace(path: path.substring(0, slash), fragment: '');
  return parent.resolve(name);
}

/// Web uses Drift's Wasm backend (`sqlite3.wasm` + `drift_worker.js` in `web/`).
/// Versions must match lockfile: drift 2.31.0, sqlite3 package 2.9.4 (see Drift docs).
QueryExecutor openAppDatabaseConnectionImpl() {
  return driftDatabase(
    name: 'couples_local_db',
    web: DriftWebOptions(
      sqlite3Wasm: _wasmAssetUri('sqlite3.wasm'),
      driftWorker: _wasmAssetUri('drift_worker.js'),
    ),
  );
}
