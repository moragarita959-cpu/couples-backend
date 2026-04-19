import '../../domain/entities/bill_record.dart';

class BillState {
  const BillState({
    this.records = const <BillRecord>[],
    this.summary = const BillSummary.empty(),
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<BillRecord> records;
  final BillSummary summary;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  BillState copyWith({
    List<BillRecord>? records,
    BillSummary? summary,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return BillState(
      records: records ?? this.records,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}
