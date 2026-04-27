import 'dart:convert';

/// In-memory fake cloud when neither `dart:html` nor `dart:io` is available.
Map<String, dynamic>? _mem;

Future<T> runWithFakeStoreImpl<T>(
  T Function(Map<String, dynamic> store) action,
) async {
  _mem ??= <String, dynamic>{
    'users': <Map<String, dynamic>>[],
    'couples': <Map<String, dynamic>>[],
    'chatMessages': <Map<String, dynamic>>[],
    'chatTyping': <Map<String, dynamic>>[],
  };
  final decoded = jsonDecode(jsonEncode(_mem)) as Map<String, dynamic>;
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
  _mem = store;
  return result;
}
