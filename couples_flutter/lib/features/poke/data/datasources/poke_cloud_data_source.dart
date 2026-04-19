import '../../../../core/network/api_client.dart';
import '../../domain/entities/poke_event.dart';

class PokeCloudDataSource {
  const PokeCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PokeEvent>> listPokeEvents({
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _apiClient.listPokeEvents(
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    return payload
        .map(
          (json) => PokeEvent(
            id: json['id'] as String,
            sender: (json['sender'] as String? ?? 'me') == 'partner'
                ? PokeSender.partner
                : PokeSender.me,
            createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
            message: json['message'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<PokeEvent> sendPoke({
    required String coupleId,
    required String currentUserId,
    required String message,
  }) async {
    final payload = await _apiClient.sendPoke(
      coupleId: coupleId,
      currentUserId: currentUserId,
      message: message,
    );
    return PokeEvent(
      id: payload['id'] as String,
      sender: (payload['sender'] as String? ?? 'me') == 'partner'
          ? PokeSender.partner
          : PokeSender.me,
      createdAt: DateTime.parse(payload['createdAt'] as String).toLocal(),
      message: payload['message'] as String? ?? '',
    );
  }
}
