import 'dart:convert';
import 'dart:io';

Future<T> runWithFakeStoreImpl<T>(
  T Function(Map<String, dynamic> store) action,
) async {
  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}couples_flutter_fake_cloud.json',
  );
  if (!await file.exists()) {
    await file.writeAsString(
      jsonEncode(<String, dynamic>{
        'users': <Map<String, dynamic>>[],
        'couples': <Map<String, dynamic>>[],
        'chatMessages': <Map<String, dynamic>>[],
        'chatTyping': <Map<String, dynamic>>[],
      }),
    );
  }

  final raw = await file.readAsString();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final store = <String, dynamic>{
    'users': List<Map<String, dynamic>>.from(
      (decoded['users'] as List<dynamic>? ?? <dynamic>[]).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    ),
    'couples': List<Map<String, dynamic>>.from(
      (decoded['couples'] as List<dynamic>? ?? <dynamic>[]).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    ),
    'chatMessages': List<Map<String, dynamic>>.from(
      (decoded['chatMessages'] as List<dynamic>? ?? <dynamic>[]).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    ),
    'chatTyping': List<Map<String, dynamic>>.from(
      (decoded['chatTyping'] as List<dynamic>? ?? <dynamic>[]).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    ),
  };

  final result = action(store);
  await file.writeAsString(jsonEncode(store));
  return result;
}
