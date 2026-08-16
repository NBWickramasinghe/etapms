import 'package:equatable/equatable.dart';

enum ReportIssueTab { request, issue, history }

enum RequestType { leave, reEntry, workwear }

enum LeaveType { sick, personal }

enum WorkwearType { shirtTShirt, trouser, shoe, jersey, winterJacket }

enum ClothingSize { s, m, l, xl, xxl }

enum IssueType { accommodation, transport, workingPlace, salary, other }

enum ReportIssueStatus { initial, loading, success, failure }

class ReportIssueState extends Equatable {
  final ReportIssueTab activeTab;
  final RequestType selectedRequestType;
  final LeaveType? selectedLeaveType;
  final WorkwearType? selectedWorkwearType;
  final ClothingSize? selectedClothingSize;
  final IssueType selectedIssueType;
  final DateTime? reEntryDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportIssueStatus status;
  final String errorMessage;

  const ReportIssueState({
    this.activeTab = ReportIssueTab.request,
    this.selectedRequestType = RequestType.leave,
    this.selectedLeaveType,
    this.selectedWorkwearType,
    this.selectedClothingSize,
    this.selectedIssueType = IssueType.accommodation,
    this.reEntryDate,
    this.startDate,
    this.endDate,
    this.status = ReportIssueStatus.initial,
    this.errorMessage = '',
  });

  ReportIssueState copyWith({
    ReportIssueTab? activeTab,
    RequestType? selectedRequestType,
    LeaveType? selectedLeaveType,
    WorkwearType? selectedWorkwearType,
    ClothingSize? selectedClothingSize,
    IssueType? selectedIssueType,
    DateTime? reEntryDate,
    DateTime? startDate,
    DateTime? endDate,
    bool clearReEntryDate = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    ReportIssueStatus? status,
    String? errorMessage,
  }) =>
      ReportIssueState(
        activeTab: activeTab ?? this.activeTab,
        selectedRequestType: selectedRequestType ?? this.selectedRequestType,
        selectedLeaveType: selectedLeaveType ?? this.selectedLeaveType,
        selectedWorkwearType:
            selectedWorkwearType ?? this.selectedWorkwearType,
        selectedClothingSize:
            selectedClothingSize ?? this.selectedClothingSize,
        selectedIssueType: selectedIssueType ?? this.selectedIssueType,
        reEntryDate:
            clearReEntryDate ? null : (reEntryDate ?? this.reEntryDate),
        startDate: clearStartDate ? null : (startDate ?? this.startDate),
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  int get leaveDays {
    if (startDate == null || endDate == null) return 0;
    // Inclusive of both the start and end day — Jul 1 to Jul 5 is 5 days.
    return endDate!.difference(startDate!).inDays + 1;
  }

  @override
  List<Object?> get props => [
        activeTab,
        selectedRequestType,
        selectedLeaveType,
        selectedWorkwearType,
        selectedClothingSize,
        selectedIssueType,
        reEntryDate,
        startDate,
        endDate,
        status,
        errorMessage,
      ];
}
