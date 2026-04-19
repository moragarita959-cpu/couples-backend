import '../../../../core/network/api_client.dart';
import '../models/bill_record_model.dart';

class BillCloudDataSource {
  const BillCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BillRecordModel>> listItems({
    required String coupleId,
    DateTime? since,
  }) async {
    final payload = await _apiClient.listBillRecords(
      coupleId: coupleId,
      since: since,
    );
    return payload.map(BillRecordModel.fromCloudJson).toList();
  }

  Future<BillRecordModel> upsertItem(BillRecordModel item) async {
    final payload = await _apiClient.upsertBillRecord(item.toCloudJson());
    return BillRecordModel.fromCloudJson(payload);
  }

  Future<void> deleteItem({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) {
    return _apiClient.deleteBillRecord(
      coupleId: coupleId,
      id: id,
      updatedAt: updatedAt,
    );
  }
}
