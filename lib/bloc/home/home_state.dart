import 'package:equatable/equatable.dart';
import '../../models/log_entry.dart';

class HomeState extends Equatable {
  final DateTime selectedDate;
  final DateTime weekStart;
  final List<LogEntry> recentLogs;
  final bool isTracking;
  final int elapsedSeconds;
  // Attendance per day — key is date at midnight
  // TODO: replace dummy data with API response
  final Map<DateTime, LogStatus> attendanceMap;

  const HomeState({
    required this.selectedDate,
    required this.weekStart,
    required this.recentLogs,
    required this.attendanceMap,
    this.isTracking = false,
    this.elapsedSeconds = 0,
  });

  factory HomeState.initial() {
    final selected = DateTime(2026, 4, 18);
    final weekStart =
        selected.subtract(Duration(days: selected.weekday - 1));
    return HomeState(
      selectedDate: selected,
      weekStart: weekStart,
      recentLogs: _sampleLogs(),
      attendanceMap: _dummyAttendance(),
    );
  }

  static List<LogEntry> _sampleLogs() => [
        LogEntry(
          date: DateTime(2026, 1, 1),
          status: LogStatus.present,
          location: 'Zikim Camp',
          startTime: '07:00 AM',
          endTime: '05:00 PM',
        ),
        LogEntry(
          date: DateTime(2026, 1, 2),
          status: LogStatus.present,
          location: 'Zikim Camp',
          startTime: '07:00 AM',
          endTime: '05:00 PM',
        ),
        LogEntry(
          date: DateTime(2026, 1, 3),
          status: LogStatus.absence,
          location: 'Zikim Camp',
        ),
        LogEntry(
          date: DateTime(2026, 1, 4),
          status: LogStatus.publicHoliday,
          location: 'Zikim Camp',
        ),
        LogEntry(
          date: DateTime(2026, 1, 5),
          status: LogStatus.present,
          location: 'Zikim Camp',
          startTime: '07:00 AM',
          endTime: '05:00 PM',
        ),
        LogEntry(
          date: DateTime(2026, 1, 6),
          status: LogStatus.publicHoliday,
          location: 'Zikim Camp',
        ),
        LogEntry(
          date: DateTime(2026, 1, 7),
          status: LogStatus.present,
          location: 'Zikim Camp',
          startTime: '07:00 AM',
          endTime: '05:00 PM',
        ),
      ];

  // Dummy attendance spanning 4 past weeks — swap with API data later
  static Map<DateTime, LogStatus> _dummyAttendance() => {
        // ── Week Apr 13–19 ──────────────────────────────────
        DateTime(2026, 4, 13): LogStatus.present,
        DateTime(2026, 4, 14): LogStatus.present,
        DateTime(2026, 4, 15): LogStatus.absence,
        DateTime(2026, 4, 16): LogStatus.present,
        DateTime(2026, 4, 17): LogStatus.present,
        DateTime(2026, 4, 18): LogStatus.present,
        DateTime(2026, 4, 19): LogStatus.publicHoliday,
        // ── Week Apr 6–12 ───────────────────────────────────
        DateTime(2026, 4, 6):  LogStatus.present,
        DateTime(2026, 4, 7):  LogStatus.publicHoliday,
        DateTime(2026, 4, 8):  LogStatus.present,
        DateTime(2026, 4, 9):  LogStatus.present,
        DateTime(2026, 4, 10): LogStatus.absence,
        DateTime(2026, 4, 11): LogStatus.present,
        DateTime(2026, 4, 12): LogStatus.publicHoliday,
        // ── Week Mar 30–Apr 5 ───────────────────────────────
        DateTime(2026, 3, 30): LogStatus.present,
        DateTime(2026, 3, 31): LogStatus.present,
        DateTime(2026, 4, 1):  LogStatus.present,
        DateTime(2026, 4, 2):  LogStatus.present,
        DateTime(2026, 4, 3):  LogStatus.present,
        DateTime(2026, 4, 4):  LogStatus.absence,
        DateTime(2026, 4, 5):  LogStatus.publicHoliday,
        // ── Week Mar 23–29 ──────────────────────────────────
        DateTime(2026, 3, 23): LogStatus.present,
        DateTime(2026, 3, 24): LogStatus.present,
        DateTime(2026, 3, 25): LogStatus.present,
        DateTime(2026, 3, 26): LogStatus.absence,
        DateTime(2026, 3, 27): LogStatus.present,
        DateTime(2026, 3, 28): LogStatus.present,
        DateTime(2026, 3, 29): LogStatus.publicHoliday,
      };

  HomeState copyWith({
    DateTime? selectedDate,
    DateTime? weekStart,
    List<LogEntry>? recentLogs,
    Map<DateTime, LogStatus>? attendanceMap,
    bool? isTracking,
    int? elapsedSeconds,
  }) =>
      HomeState(
        selectedDate:  selectedDate  ?? this.selectedDate,
        weekStart:     weekStart     ?? this.weekStart,
        recentLogs:    recentLogs    ?? this.recentLogs,
        attendanceMap: attendanceMap ?? this.attendanceMap,
        isTracking:    isTracking    ?? this.isTracking,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );

  @override
  // attendanceMap excluded — static dummy data, equality via identity is fine
  List<Object?> get props =>
      [selectedDate, weekStart, recentLogs, isTracking, elapsedSeconds];
}
