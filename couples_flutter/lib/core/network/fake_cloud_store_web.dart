import 'dart:convert';

import 'package:web/web.dart';

const _storageKey = 'couples_flutter_fake_cloud';

Future<T> runWithFakeStoreImpl<T>(
  T Function(Map<String, dynamic> store) action,
) async {
  final storage = window.localStorage;
  final existing = storage.getItem(_storageKey);
  final jsonStr = existing ??
      jsonEncode(<String, dynamic>{
        'users': <Map<String, dynamic>>[],
        'couples': <Map<String, dynamic>>[],
        'chatMessages': <Map<String, dynamic>>[],
        'chatTyping': <Map<String, dynamic>>[],
      });
  if (existing == null) {
    storage.setItem(_storageKey, jsonStr);
  }

  final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
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
  storage.setItem(_storageKey, jsonEncode(store));
  return result;
}
