import 'package:flutter_bloc/flutter_bloc.dart';
import 'report_issue_state.dart';

class ReportIssueCubit extends Cubit<ReportIssueState> {
  ReportIssueCubit() : super(const ReportIssueState());

  void selectTab(ReportIssueTab tab) => emit(
        state.copyWith(
          activeTab: tab,
          status: ReportIssueStatus.initial,
          errorMessage: '',
        ),
      );

  void selectRequestType(RequestType type) =>
      emit(state.copyWith(selectedRequestType: type));

  void selectLeaveType(LeaveType type) =>
      emit(state.copyWith(selectedLeaveType: type));

  void selectWorkwearType(WorkwearType type) =>
      emit(state.copyWith(selectedWorkwearType: type));

  void selectClothingSize(ClothingSize size) =>
      emit(state.copyWith(selectedClothingSize: size));

  void selectIssueType(IssueType type) =>
      emit(state.copyWith(selectedIssueType: type));

  void selectStartDate(DateTime date) {
    final endDate = state.endDate;
    emit(state.copyWith(
      startDate: date,
      clearEndDate: endDate != null && endDate.isBefore(date),
    ));
  }

  void selectEndDate(DateTime date) =>
      emit(state.copyWith(endDate: date));

  void selectReEntryDate(DateTime date) {
    final startDate = state.startDate;
    final endDate = state.endDate;
    // The vacation start/end dates must fall between today and the
    // re-entry date — if they no longer fit under the new re-entry date,
    // clear them so an invalid range can't linger.
    final startInvalid = startDate != null && startDate.isAfter(date);
    final endInvalid = endDate != null && endDate.isAfter(date);
    emit(state.copyWith(
      reEntryDate: date,
      clearStartDate: startInvalid,
      clearEndDate: startInvalid || endInvalid,
    ));
  }

  Future<void> submitRequest(String reason) async {
    final needsDates = state.selectedRequestType != RequestType.workwear;
    final isReEntry = state.selectedRequestType == RequestType.reEntry;
    if (isReEntry && state.reEntryDate == null) {
      emit(state.copyWith(
        status: ReportIssueStatus.failure,
        errorMessage: 'Please select a re-entry date.',
      ));
      return;
    }
    if (needsDates && (state.startDate == null || state.endDate == null)) {
      emit(state.copyWith(
        status: ReportIssueStatus.failure,
        errorMessage: 'Please select start and end dates.',
      ));
      return;
    }
    emit(state.copyWith(
        status: ReportIssueStatus.loading, errorMessage: ''));
    await Future.delayed(const Duration(milliseconds: 800));
    // API integration point — replace with real request submission
    emit(state.copyWith(status: ReportIssueStatus.success));
  }

  Future<void> submitIssue(String description) async {
    if (description.trim().isEmpty) {
      emit(state.copyWith(
        status: ReportIssueStatus.failure,
        errorMessage: 'Please describe the issue.',
      ));
      return;
    }
    emit(state.copyWith(
        status: ReportIssueStatus.loading, errorMessage: ''));
    await Future.delayed(const Duration(milliseconds: 800));
    // API integration point — replace with real issue submission
    emit(state.copyWith(status: ReportIssueStatus.success));
  }
}
