import 'package:equatable/equatable.dart';

enum ReportIssueTab { request, issue }

enum RequestType { leave, reEntry, workwear }

enum IssueType { accommodation, transport, workingPlace, salary, other }

enum ReportIssueStatus { initial, loading, success, failure }

class ReportIssueState extends Equatable {
  final ReportIssueTab activeTab;
  final RequestType selectedRequestType;
  final IssueType selectedIssueType;
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportIssueStatus status;
  final String errorMessage;

  const ReportIssueState({
    this.activeTab = ReportIssueTab.request,
    this.selectedRequestType = RequestType.leave,
    this.selectedIssueType = IssueType.accommodation,
    this.startDate,
    this.endDate,
    this.status = ReportIssueStatus.initial,
    this.errorMessage = '',
  });

  ReportIssueState copyWith({
    ReportIssueTab? activeTab,
    RequestType? selectedRequestType,
    IssueType? selectedIssueType,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
    ReportIssueStatus? status,
    String? errorMessage,
  }) =>
      ReportIssueState(
        activeTab: activeTab ?? this.activeTab,
        selectedRequestType: selectedRequestType ?? this.selectedRequestType,
        selectedIssueType: selectedIssueType ?? this.selectedIssueType,
        startDate: clearStartDate ? null : (startDate ?? this.startDate),
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  int get leaveDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays;
  }

  @override
  List<Object?> get props => [
        activeTab,
        selectedRequestType,
        selectedIssueType,
        startDate,
        endDate,
        status,
        errorMessage,
      ];
}
