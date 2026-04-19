import '../entities/bill_record.dart';
import '../repositories/bill_repository.dart';

class InsertBillRecord {
  const InsertBillRecord(this._repository);

  final BillRepository _repository;

  Future<BillRecord> call(BillRecord item) {
    return _repository.insert(item);
  }
}
