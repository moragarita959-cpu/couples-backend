import '../../../../core/network/api_client.dart';
import '../models/countdown_event_model.dart';

class CountdownCloudDataSource {
  const CountdownCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CountdownEventModel>> listItems({
    required String coupleId,
    DateTime? since,
  }) async {
    final payload = await _apiClient.listCountdownEvents(
      coupleId: coupleId,
      since: since,
    );
    return payload.map(CountdownEventModel.fromCloudJson).toList();
  }

  Future<CountdownEventModel> upsertItem(CountdownEventModel item) async {
    final payload = await _apiClient.upsertCountdownEvent(item.toCloudJson());
    return CountdownEventModel.fromCloudJson(payload);
  }

  Future<void> deleteItem({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) {
    return _apiClient.deleteCountdownEvent(
      coupleId: coupleId,
      id: id,
      updatedAt: updatedAt,
    );
  }
}
