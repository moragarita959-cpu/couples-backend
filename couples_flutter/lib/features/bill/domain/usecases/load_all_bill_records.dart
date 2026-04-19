import '../entities/bill_record.dart';
import '../repositories/bill_repository.dart';

class LoadAllBillRecords {
  const LoadAllBillRecords(this._repository);

  final BillRepository _repository;

  Future<List<BillRecord>> call({required String coupleId}) {
    return _repository.loadAll(coupleId: coupleId);
  }
}
