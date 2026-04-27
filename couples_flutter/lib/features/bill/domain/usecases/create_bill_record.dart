import '../entities/bill_record.dart';
import '../repositories/bill_repository.dart';

class CreateBillRecord {
  const CreateBillRecord(this._repository);

  final BillRepository _repository;

  Future<BillRecord> call(
    BillType type,
    String categoryKey,
    double amount,
    String note, {
    required String ownerUserId,
    required String coupleId,
  }) {
    return _repository.createRecord(
      type,
      categoryKey,
      amount,
      note,
      ownerUserId: ownerUserId,
      coupleId: coupleId,
    );
  }
}
