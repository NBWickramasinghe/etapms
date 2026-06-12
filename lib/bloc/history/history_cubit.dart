import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/log_entry.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryState(logs: _dummyLogs));

  void selectStartDate(DateTime date) =>
      emit(state.copyWith(startDate: date));

  void selectEndDate(DateTime date) =>
      emit(state.copyWith(endDate: date));

  // TODO: replace body with API call: api.fetchHistory(startDate, endDate)
  void applyFilter() {
    if (!state.canFilter) return;
    emit(state.copyWith(isLoading: true));
    final filtered = _dummyLogs.where((e) =>
        !e.date.isBefore(state.startDate!) &&
        !e.date.isAfter(state.endDate!)).toList();
    emit(state.copyWith(isLoading: false, logs: filtered));
  }

  // Dummy data — replace with API response (List<LogEntry>.fromJson)
  static final List<LogEntry> _dummyLogs = [
    LogEntry(date: DateTime(2026,1,1),  status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,2),  status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,3),  status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,4),  status: LogStatus.absence,       location: 'Zikim'),
    LogEntry(date: DateTime(2026,1,5),  status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,6),  status: LogStatus.publicHoliday, location: 'Zikim'),
    LogEntry(date: DateTime(2026,1,7),  status: LogStatus.publicHoliday, location: 'Zikim'),
    LogEntry(date: DateTime(2026,1,8),  status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,9),  status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,10), status: LogStatus.absence,       location: 'Zikim'),
    LogEntry(date: DateTime(2026,1,11), status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,12), status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,13), status: LogStatus.publicHoliday, location: 'Zikim'),
    LogEntry(date: DateTime(2026,1,14), status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
    LogEntry(date: DateTime(2026,1,15), status: LogStatus.present,       location: 'Zikim', startTime: '07:00 AM', endTime: '05:00 PM'),
  ];
}
