import '../entities/bill_record.dart';
import '../repositories/bill_repository.dart';

class GetBillRecords {
  const GetBillRecords(this._repository);

  final BillRepository _repository;

  Future<List<BillRecord>> call() {
    return _repository.getRecords();
  }
}
