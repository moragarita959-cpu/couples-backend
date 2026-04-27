import 'fake_cloud_store_stub.dart'
    if (dart.library.html) 'fake_cloud_store_web.dart'
    if (dart.library.io) 'fake_cloud_store_io.dart';

Future<T> runWithFakeStore<T>(
  T Function(Map<String, dynamic> store) action,
) =>
    runWithFakeStoreImpl(action);
