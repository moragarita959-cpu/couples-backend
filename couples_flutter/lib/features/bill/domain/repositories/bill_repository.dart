import '../entities/bill_record.dart';

abstract class BillRepository {
  Future<List<BillRecord>> loadAll({required String coupleId});
  Future<List<BillRecord>> refresh({required String coupleId});
  Future<BillRecord> insert(BillRecord item);
  Future<BillRecord> update(BillRecord item);
  Future<void> delete({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  });
  Future<BillSummary> getSummary({String coupleId = ''});

  Future<BillRecord> createRecord(
    BillType type,
    BillCategory category,
    double amount,
    String note,
  );

  Future<List<BillRecord>> getRecords();
}
