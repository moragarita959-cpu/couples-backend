import '../entities/bill_record.dart';
import '../repositories/bill_repository.dart';

class GetBillSummary {
  const GetBillSummary(this._repository);

  final BillRepository _repository;

  Future<BillSummary> call() {
    return _repository.getSummary();
  }
}
