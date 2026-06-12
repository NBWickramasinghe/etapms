import '../../models/log_entry.dart';

class HistoryState {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final List<LogEntry> logs;

  const HistoryState({
    this.startDate,
    this.endDate,
    this.isLoading = false,
    this.logs = const [],
  });

  bool get canFilter => startDate != null && endDate != null;

  HistoryState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool clearStart = false,
    bool clearEnd = false,
    bool? isLoading,
    List<LogEntry>? logs,
  }) {
    return HistoryState(
      startDate:  clearStart ? null : (startDate  ?? this.startDate),
      endDate:    clearEnd   ? null : (endDate    ?? this.endDate),
      isLoading:  isLoading  ?? this.isLoading,
      logs:       logs       ?? this.logs,
    );
  }
}
