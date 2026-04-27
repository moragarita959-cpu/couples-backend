import '../repositories/bill_repository.dart';

class DeleteBillRecord {
  const DeleteBillRecord(this._repository);

  final BillRepository _repository;

  Future<void> call({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
    required String actorUserId,
  }) {
    return _repository.delete(
      id: id,
      coupleId: coupleId,
      updatedAt: updatedAt,
      actorUserId: actorUserId,
    );
  }
}
