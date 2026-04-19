import '../entities/bill_record.dart';
import '../repositories/bill_repository.dart';

class CreateBillRecord {
  const CreateBillRecord(this._repository);

  final BillRepository _repository;

  Future<BillRecord> call(
    BillType type,
    BillCategory category,
    double amount,
    String note,
  ) {
    return _repository.createRecord(type, category, amount, note);
  }
}
