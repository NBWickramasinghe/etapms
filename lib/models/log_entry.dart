enum LogStatus { present, absence, publicHoliday }

class LogEntry {
  final DateTime date;
  final LogStatus status;
  final String location;
  final String? startTime;
  final String? endTime;

  const LogEntry({
    required this.date,
    required this.status,
    required this.location,
    this.startTime,
    this.endTime,
  });
}
