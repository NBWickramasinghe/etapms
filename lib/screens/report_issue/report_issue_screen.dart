import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../bloc/report_issue/report_issue_cubit.dart';
import '../../bloc/report_issue/report_issue_state.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';

const _kDark  = Color(0xFF242F31);
const _kGreen = Color(0xFF354E48);
const _kText  = Color(0xFF191C21);
const _kRed   = Color(0xFFBF3847);
const _kBg    = Color(0xFFF5F0E8);
const _kAmber = Color(0xFFD4882A);

/// Today's date with the time stripped — so "today" is always a valid
/// pick regardless of the current time of day.
DateTime _todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportIssueCubit(),
      child: const _ReportIssueView(),
    );
  }
}

class _ReportIssueView extends StatefulWidget {
  const _ReportIssueView();

  @override
  State<_ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends State<_ReportIssueView> {
  final _reasonCtrl = TextEditingController();
  final _issueCtrl  = TextEditingController();
  final _shoeSizeCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _issueCtrl.dispose();
    _shoeSizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocConsumer<ReportIssueCubit, ReportIssueState>(
      listener: (context, state) {
        if (state.status == ReportIssueStatus.success) {
          final msg = state.activeTab == ReportIssueTab.request
              ? l.requestSubmitted
              : l.issueReported;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg,
                  style: GoogleFonts.poppins(fontSize: context.sp(13))),
              backgroundColor: _kGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final cubit = context.read<ReportIssueCubit>();

        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(20),
                    vertical: context.sp(14),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            width: context.sp(40),
                            height: context.sp(40),
                            child: Center(
                              child: Icon(Icons.arrow_back,
                                  color: _kText, size: context.sp(20)),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        l.requestIssue,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(19),
                          fontWeight: FontWeight.w700,
                          color: _kText,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Tab Row ──────────────────────────────────────
                _TabRow(
                  activeTab: state.activeTab,
                  onTabSelected: cubit.selectTab,
                ),

                // ── Scrollable Content ───────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.sp(20),
                      vertical: context.sp(16),
                    ),
                    child: switch (state.activeTab) {
                      ReportIssueTab.request => _RequestContent(
                          state: state,
                          cubit: cubit,
                          reasonCtrl: _reasonCtrl,
                          shoeSizeCtrl: _shoeSizeCtrl,
                        ),
                      ReportIssueTab.issue => _IssueContent(
                          state: state,
                          cubit: cubit,
                          issueCtrl: _issueCtrl,
                        ),
                      ReportIssueTab.history => const _HistoryContent(),
                    },
                  ),
                ),

                // ── Error ────────────────────────────────────────
                if (state.activeTab != ReportIssueTab.history &&
                    state.errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                    child: Text(
                      state.errorMessage,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(12),
                        color: _kRed,
                        letterSpacing: 0,
                      ),
                    ),
                  ),

                // ── Bottom Button (hidden on the History tab) ─────
                if (state.activeTab != ReportIssueTab.history)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.sp(20),
                      context.sp(8),
                      context.sp(20),
                      context.sp(16),
                    ),
                    child: _ActionButton(
                      label: state.activeTab == ReportIssueTab.request
                          ? l.request
                          : l.reportIssue,
                      isLoading: state.status == ReportIssueStatus.loading,
                      onTap: () {
                        if (state.activeTab == ReportIssueTab.request) {
                          cubit.submitRequest(_reasonCtrl.text);
                        } else {
                          cubit.submitIssue(_issueCtrl.text);
                        }
                      },
                    ),
                  )
                else
                  SizedBox(height: context.sp(16)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tab Row ───────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  final ReportIssueTab activeTab;
  final ValueChanged<ReportIssueTab> onTabSelected;

  const _TabRow({required this.activeTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        _TabItem(
          label: l.request,
          isSelected: activeTab == ReportIssueTab.request,
          onTap: () => onTabSelected(ReportIssueTab.request),
        ),
        _TabItem(
          label: l.issue,
          isSelected: activeTab == ReportIssueTab.issue,
          onTap: () => onTabSelected(ReportIssueTab.issue),
        ),
        _TabItem(
          label: l.history,
          isSelected: activeTab == ReportIssueTab.history,
          onTap: () => onTabSelected(ReportIssueTab.history),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.sp(12)),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _kGreen : _kText.withValues(alpha: 0.4),
                  letterSpacing: 0,
                ),
              ),
            ),
            Container(
              height: 2,
              color: isSelected ? _kGreen : Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Request Tab Content ───────────────────────────────────────────────────────

class _RequestContent extends StatelessWidget {
  final ReportIssueState state;
  final ReportIssueCubit cubit;
  final TextEditingController reasonCtrl;
  final TextEditingController shoeSizeCtrl;

  const _RequestContent({
    required this.state,
    required this.cubit,
    required this.reasonCtrl,
    required this.shoeSizeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.selectRequestType,
          style: GoogleFonts.poppins(
            fontSize: context.sp(13),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(12)),

        _ChipGrid(
          children: [
            _TypeChip(
              label: l.leave,
              isSelected: state.selectedRequestType == RequestType.leave,
              onTap: () => cubit.selectRequestType(RequestType.leave),
            ),
            _TypeChip(
              label: l.reEntry,
              isSelected: state.selectedRequestType == RequestType.reEntry,
              onTap: () => cubit.selectRequestType(RequestType.reEntry),
            ),
            _TypeChip(
              label: l.workwear,
              isSelected: state.selectedRequestType == RequestType.workwear,
              onTap: () => cubit.selectRequestType(RequestType.workwear),
            ),
          ],
        ),

        if (state.selectedRequestType == RequestType.leave) ...[
          SizedBox(height: context.sp(20)),
          _LeaveTypeField(
            value: state.selectedLeaveType,
            onChanged: cubit.selectLeaveType,
          ),
        ],

        if (state.selectedRequestType == RequestType.workwear) ...[
          SizedBox(height: context.sp(20)),
          _LabeledDropdown<WorkwearType>(
            label: l.workwearType,
            hint: l.selectWorkwearType,
            value: state.selectedWorkwearType,
            items: [
              DropdownMenuItem(
                value: WorkwearType.shirtTShirt,
                child: Text(l.shirtTShirt),
              ),
              DropdownMenuItem(
                value: WorkwearType.trouser,
                child: Text(l.trouser),
              ),
              DropdownMenuItem(
                value: WorkwearType.shoe,
                child: Text(l.shoe),
              ),
              DropdownMenuItem(
                value: WorkwearType.jersey,
                child: Text(l.jersey),
              ),
              DropdownMenuItem(
                value: WorkwearType.winterJacket,
                child: Text(l.winterJacket),
              ),
            ],
            onChanged: cubit.selectWorkwearType,
          ),
          SizedBox(height: context.sp(16)),
          if (state.selectedWorkwearType == WorkwearType.shoe)
            _ShoeSizeField(controller: shoeSizeCtrl)
          else
            _LabeledDropdown<ClothingSize>(
              label: l.size,
              hint: l.selectSize,
              value: state.selectedClothingSize,
              items: const [
                DropdownMenuItem(value: ClothingSize.s, child: Text('S')),
                DropdownMenuItem(value: ClothingSize.m, child: Text('M')),
                DropdownMenuItem(value: ClothingSize.l, child: Text('L')),
                DropdownMenuItem(value: ClothingSize.xl, child: Text('XL')),
                DropdownMenuItem(value: ClothingSize.xxl, child: Text('XXL')),
              ],
              onChanged: cubit.selectClothingSize,
            ),
        ],

        if (state.selectedRequestType != RequestType.workwear) ...[
          if (state.selectedRequestType == RequestType.reEntry) ...[
            SizedBox(height: context.sp(20)),
            _DateField(
              label: l.reEntryDate,
              date: state.reEntryDate,
              onTap: () async {
                final today = _todayDate();
                final d = await showDatePicker(
                  context: context,
                  initialDate: state.reEntryDate ?? today,
                  // The re-entry date is always an upcoming date — never
                  // in the past.
                  firstDate: today,
                  lastDate: DateTime(2030),
                  builder: (ctx, child) => _datePickerTheme(ctx, child),
                );
                if (d != null) cubit.selectReEntryDate(d);
              },
            ),
          ],

          SizedBox(height: context.sp(20)),

          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: l.startDate,
                  date: state.startDate,
                  onTap: () async {
                    final today = _todayDate();
                    // For Vacation & Re Entry, the start date must fall
                    // between today and the chosen re-entry date.
                    final maxSelectable =
                        state.selectedRequestType == RequestType.reEntry
                            ? (state.reEntryDate ?? DateTime(2030))
                            : DateTime(2030);
                    final d = await showDatePicker(
                      context: context,
                      initialDate: state.startDate ?? today,
                      // Only today or upcoming dates can be picked as start.
                      firstDate: today,
                      lastDate: maxSelectable,
                      builder: (ctx, child) => _datePickerTheme(ctx, child),
                    );
                    if (d != null) cubit.selectStartDate(d);
                  },
                ),
              ),
              SizedBox(width: context.sp(12)),
              Expanded(
                child: _DateField(
                  label: l.endDate,
                  date: state.endDate,
                  onTap: () async {
                    final firstSelectable = state.startDate ?? _todayDate();
                    // For Vacation & Re Entry, the end date must fall
                    // between the start date and the chosen re-entry date.
                    final maxSelectable =
                        state.selectedRequestType == RequestType.reEntry
                            ? (state.reEntryDate ?? DateTime(2030))
                            : DateTime(2030);
                    final d = await showDatePicker(
                      context: context,
                      initialDate: state.endDate ?? firstSelectable,
                      firstDate: firstSelectable,
                      lastDate: maxSelectable,
                      builder: (ctx, child) => _datePickerTheme(ctx, child),
                    );
                    if (d != null) cubit.selectEndDate(d);
                  },
                ),
              ),
            ],
          ),

          if (state.startDate != null && state.endDate != null) ...[
            SizedBox(height: context.sp(16)),
            _DateSummaryCard(
              startDate: state.startDate!,
              endDate: state.endDate!,
              leaveDays: state.leaveDays,
              requestType: state.selectedRequestType,
            ),
          ],
        ],

        SizedBox(height: context.sp(20)),

        _TextAreaField(
          controller: reasonCtrl,
          label: l.reasonOptional,
          hint: l.enterReason,
        ),
      ],
    );
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: _kGreen,
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
      ),
      child: child!,
    );
  }
}

class _LeaveTypeField extends StatelessWidget {
  final LeaveType? value;
  final ValueChanged<LeaveType> onChanged;

  const _LeaveTypeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.leaveType,
          style: GoogleFonts.poppins(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(6)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _kGreen.withValues(alpha: 0.4),
              width: 1.3,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LeaveType>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  size: context.sp(18), color: _kDark),
              hint: Text(
                l.selectLeaveType,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w400,
                  color: _kText.withValues(alpha: 0.35),
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w400,
                color: _kText,
              ),
              dropdownColor: Colors.white,
              items: [
                DropdownMenuItem(
                  value: LeaveType.sick,
                  child: Text(l.sickLeave),
                ),
                DropdownMenuItem(
                  value: LeaveType.personal,
                  child: Text(l.personalLeave),
                ),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Generic labeled dropdown — used by the Workwear Type / Size fields.
class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(6)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _kGreen.withValues(alpha: 0.4),
              width: 1.3,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  size: context.sp(18), color: _kDark),
              hint: Text(
                hint,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w400,
                  color: _kText.withValues(alpha: 0.35),
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w400,
                color: _kText,
              ),
              dropdownColor: Colors.white,
              items: items,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ShoeSizeField extends StatelessWidget {
  final TextEditingController controller;

  const _ShoeSizeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.shoeSize,
          style: GoogleFonts.poppins(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(6)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _kGreen.withValues(alpha: 0.4),
              width: 1.3,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w400,
              color: _kText,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              hintText: l.enterShoeSize,
              hintStyle: GoogleFonts.poppins(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w400,
                color: _kText.withValues(alpha: 0.35),
                letterSpacing: 0,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.sp(12),
                vertical: context.sp(13),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Issue Tab Content ─────────────────────────────────────────────────────────

class _IssueContent extends StatelessWidget {
  final ReportIssueState state;
  final ReportIssueCubit cubit;
  final TextEditingController issueCtrl;

  const _IssueContent({
    required this.state,
    required this.cubit,
    required this.issueCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.selectIssueType,
          style: GoogleFonts.poppins(
            fontSize: context.sp(13),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(12)),

        _ChipGrid(
          children: [
            _TypeChip(
              label: l.accommodation,
              isSelected: state.selectedIssueType == IssueType.accommodation,
              onTap: () => cubit.selectIssueType(IssueType.accommodation),
            ),
            _TypeChip(
              label: l.transport,
              isSelected: state.selectedIssueType == IssueType.transport,
              onTap: () => cubit.selectIssueType(IssueType.transport),
            ),
            _TypeChip(
              label: l.workingPlace,
              isSelected: state.selectedIssueType == IssueType.workingPlace,
              onTap: () => cubit.selectIssueType(IssueType.workingPlace),
            ),
            _TypeChip(
              label: l.salary,
              isSelected: state.selectedIssueType == IssueType.salary,
              onTap: () => cubit.selectIssueType(IssueType.salary),
            ),
            _TypeChip(
              label: l.other,
              isSelected: state.selectedIssueType == IssueType.other,
              onTap: () => cubit.selectIssueType(IssueType.other),
            ),
          ],
        ),

        SizedBox(height: context.sp(20)),

        _TextAreaField(
          controller: issueCtrl,
          label: l.issue,
          hint: l.describeIssue,
        ),
      ],
    );
  }
}

// ── History Tab Content ───────────────────────────────────────────────────────

enum _HistoryStatus { approved, pending, rejected }

class _HistoryEntry {
  final RequestType? requestType;
  final IssueType? issueType;
  final DateTime date;
  final String detail;
  // Day count for leave requests only — null for everything else.
  final int? leaveDays;
  // The note the employee submitted with the request/issue — editable
  // while the submission is still pending.
  final String reason;
  final _HistoryStatus status;

  const _HistoryEntry({
    this.requestType,
    this.issueType,
    required this.date,
    required this.detail,
    this.leaveDays,
    required this.reason,
    required this.status,
  });

  _HistoryEntry copyWith({String? reason}) => _HistoryEntry(
        requestType: requestType,
        issueType: issueType,
        date: date,
        detail: detail,
        leaveDays: leaveDays,
        reason: reason ?? this.reason,
        status: status,
      );
}

String _historyTitle(AppLocalizations l, _HistoryEntry entry) {
  if (entry.requestType != null) {
    return switch (entry.requestType!) {
      RequestType.leave => l.leave,
      RequestType.reEntry => l.reEntry,
      RequestType.workwear => l.workwear,
    };
  }
  return switch (entry.issueType!) {
    IssueType.accommodation => l.accommodation,
    IssueType.transport => l.transport,
    IssueType.workingPlace => l.workingPlace,
    IssueType.salary => l.salary,
    IssueType.other => l.other,
  };
}

(String, Color) _historyStatusInfo(AppLocalizations l, _HistoryStatus status) =>
    switch (status) {
      _HistoryStatus.approved => (l.approved, _kGreen),
      _HistoryStatus.pending => (l.pending, _kAmber),
      _HistoryStatus.rejected => (l.rejected, _kRed),
    };

// Dummy past submissions — API integration point — replace with real history
final _dummyHistory = <_HistoryEntry>[
  _HistoryEntry(
    requestType: RequestType.leave,
    date: DateTime(2026, 4, 10),
    detail: '12 Apr 2026 — 14 Apr 2026',
    leaveDays: 3,
    reason: 'Family function back home.',
    status: _HistoryStatus.approved,
  ),
  _HistoryEntry(
    issueType: IssueType.accommodation,
    date: DateTime(2026, 3, 22),
    detail: 'Room maintenance request',
    reason: 'Bathroom tap has been leaking for two days.',
    status: _HistoryStatus.pending,
  ),
  _HistoryEntry(
    requestType: RequestType.workwear,
    date: DateTime(2026, 2, 15),
    detail: 'Size L jacket replacement',
    reason: 'Current jacket zipper is broken.',
    status: _HistoryStatus.rejected,
  ),
  _HistoryEntry(
    requestType: RequestType.reEntry,
    date: DateTime(2026, 1, 30),
    detail: '05 Feb 2026 — 08 Feb 2026',
    reason: 'Visa renewal appointment.',
    status: _HistoryStatus.approved,
  ),
];

class _HistoryContent extends StatefulWidget {
  const _HistoryContent();

  @override
  State<_HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<_HistoryContent> {
  final _entries = List<_HistoryEntry>.of(_dummyHistory);

  Future<void> _openDetail(int index) async {
    final updated = await showGeneralDialog<_HistoryEntry>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
      pageBuilder: (context, _, _) =>
          _HistoryDetailDialog(entry: _entries[index]),
    );
    if (updated != null) setState(() => _entries[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: context.sp(40)),
        child: Center(
          child: Text(
            l.noHistoryFound,
            style: GoogleFonts.poppins(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w500,
              color: _kText.withValues(alpha: 0.35),
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _entries.length; i++) ...[
          _HistoryCard(
            entry: _entries[i],
            onTap: () => _openDetail(i),
          ),
          SizedBox(height: context.sp(12)),
        ],
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final _HistoryEntry entry;
  final VoidCallback onTap;

  const _HistoryCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final (statusLabel, statusColor) = _historyStatusInfo(l, entry.status);
    final showDays =
        entry.requestType == RequestType.leave && entry.leaveDays != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.sp(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: _kGreen.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _historyTitle(l, entry),
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w700,
                      color: _kText,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: context.sp(4)),
                  Text(
                    showDays
                        ? '${entry.detail}  ·  ${entry.leaveDays} ${l.days}'
                        : entry.detail,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.w400,
                      color: _kText.withValues(alpha: 0.6),
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: context.sp(6)),
                  Text(
                    DateFormat('dd MMM yyyy', locale).format(entry.date),
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w400,
                      color: _kText.withValues(alpha: 0.4),
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.sp(10)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(10),
                vertical: context.sp(5),
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(10.5),
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── History detail dialog — view, and edit while pending ───────────────────────

class _HistoryDetailDialog extends StatefulWidget {
  final _HistoryEntry entry;

  const _HistoryDetailDialog({required this.entry});

  @override
  State<_HistoryDetailDialog> createState() => _HistoryDetailDialogState();
}

class _HistoryDetailDialogState extends State<_HistoryDetailDialog> {
  late bool _editing = false;
  late final _reasonCtrl = TextEditingController(text: widget.entry.reason);

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final entry = widget.entry;
    final (statusLabel, statusColor) = _historyStatusInfo(l, entry.status);
    final showDays =
        entry.requestType == RequestType.leave && entry.leaveDays != null;
    // Editing is only offered while a submission is still pending.
    // TODO: once wired to the API, also enforce the 24-hour edit window
    // from the submission date — this demo skips that time check.
    final canEdit = entry.status == _HistoryStatus.pending;
    final screen = MediaQuery.sizeOf(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: math.min(420.0, screen.width * 0.92),
              maxHeight: screen.height * 0.86,
            ),
            child: Container(
              // Give the scroll view a finite viewport. A max-height constraint
              // alone lets its child be measured at an unbounded height.
              height: screen.height * 0.86,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.sp(14)),
              ),
              padding: EdgeInsets.all(context.sp(20)),
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _historyTitle(l, entry),
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.w700,
                            color: _kText,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: EdgeInsets.all(context.sp(4)),
                          child: Icon(
                            Icons.close,
                            size: context.sp(20),
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.sp(12)),

                  // ── Status badge ────────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.sp(10),
                      vertical: context.sp(5),
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: context.sp(16)),

                  // ── Detail rows ─────────────────────────────
                  _DetailRow(label: 'Detail', value: entry.detail),
                  if (showDays)
                    _DetailRow(
                      label: 'Duration',
                      value: '${entry.leaveDays} ${l.days}',
                    ),
                  _DetailRow(
                    label: 'Submitted',
                    value: DateFormat('dd MMM yyyy', locale).format(
                      entry.date,
                    ),
                  ),

                  SizedBox(height: context.sp(16)),
                  Text(
                    l.reasonOptional,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.w600,
                      color: _kText,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: context.sp(6)),
                  if (_editing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _kGreen.withValues(alpha: 0.4),
                          width: 1.3,
                        ),
                      ),
                      child: TextField(
                        controller: _reasonCtrl,
                        minLines: 3,
                        maxLines: 5,
                        autofocus: true,
                        // Suppresses the platform's yellow spellcheck/
                        // autocorrect underline under composed text.
                        autocorrect: false,
                        enableSuggestions: false,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.w400,
                          color: _kText,
                          letterSpacing: 0,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(context.sp(12)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                      ),
                    )
                  else
                    Text(
                      entry.reason.isEmpty ? '—' : entry.reason,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w400,
                        color: _kText.withValues(alpha: 0.7),
                        letterSpacing: 0,
                        height: 1.4,
                      ),
                    ),

                  if (canEdit) ...[
                    SizedBox(height: context.sp(20)),
                    if (_editing)
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Cancel',
                              isLoading: false,
                              onTap: () => setState(() {
                                _editing = false;
                                _reasonCtrl.text = entry.reason;
                              }),
                            ),
                          ),
                          SizedBox(width: context.sp(10)),
                          Expanded(
                            child: _SaveButton(
                              onTap: () => Navigator.of(context).pop(
                                entry.copyWith(reason: _reasonCtrl.text),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _EditButton(
                        onTap: () => setState(() => _editing = true),
                      ),
                  ],
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.sp(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.sp(84),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w500,
                color: _kText.withValues(alpha: 0.5),
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: context.sp(12.5),
                fontWeight: FontWeight.w600,
                color: _kText,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: context.sp(46),
        decoration: BoxDecoration(border: Border.all(color: _kGreen)),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, color: _kGreen, size: context.sp(16)),
              SizedBox(width: context.sp(6)),
              Text(
                'Edit',
                style: GoogleFonts.poppins(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                  color: _kGreen,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: context.sp(46),
        color: _kGreen,
        child: Center(
          child: Text(
            'Save',
            style: GoogleFonts.poppins(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _ChipGrid extends StatelessWidget {
  final List<Widget> children;

  const _ChipGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      final isLast = i + 1 >= children.length;
      rows.add(Row(
        children: [
          Expanded(child: children[i]),
          SizedBox(width: context.sp(10)),
          Expanded(child: isLast ? const SizedBox() : children[i + 1]),
        ],
      ));
      if (i + 2 < children.length) rows.add(SizedBox(height: context.sp(10)));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: context.sp(44)),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(8),
          vertical: context.sp(6),
        ),
        decoration: BoxDecoration(
          color: isSelected ? _kGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kGreen, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: context.sp(12),
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : _kText,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final hasDate = date != null;
    final displayText = hasDate
        ? DateFormat('dd MMM yyyy', locale).format(date!)
        : l.selectDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(6)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.sp(12),
              vertical: context.sp(13),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _kGreen.withValues(alpha: 0.4),
                width: 1.3,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: context.sp(18), color: _kDark),
                SizedBox(width: context.sp(8)),
                Expanded(
                  child: Text(
                    displayText,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.w400,
                      color: hasDate
                          ? _kText
                          : _kText.withValues(alpha: 0.35),
                      letterSpacing: 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DateSummaryCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int leaveDays;
  final RequestType requestType;

  const _DateSummaryCard({
    required this.startDate,
    required this.endDate,
    required this.leaveDays,
    required this.requestType,
  });

  String _fmt(DateTime d, String locale) =>
      DateFormat('dd MMM yyyy', locale).format(d);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final typeLabel = switch (requestType) {
      RequestType.leave    => l.leave,
      RequestType.reEntry  => l.reEntry,
      RequestType.workwear => l.workwear,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: context.sp(16),
        horizontal: context.sp(16),
      ),
      color: _kGreen,
      child: Column(
        children: [
          Text(
            '${_fmt(startDate, locale)} — ${_fmt(endDate, locale)}',
            style: GoogleFonts.poppins(
              fontSize: context.sp(12),
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: context.sp(4)),
          Text(
            '${leaveDays.toString().padLeft(2, '0')} ${l.days} · $typeLabel',
            style: GoogleFonts.poppins(
              fontSize: context.sp(19),
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _TextAreaField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(6)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _kGreen.withValues(alpha: 0.4),
              width: 1.3,
            ),
          ),
          child: TextField(
            controller: controller,
            minLines: 6,
            maxLines: 10,
            style: GoogleFonts.poppins(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w400,
              color: _kText,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w400,
                color: _kText.withValues(alpha: 0.35),
                letterSpacing: 0,
              ),
              contentPadding: EdgeInsets.all(context.sp(14)),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: context.sp(50),
        color: _kDark,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: context.sp(22),
                  height: context.sp(22),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                ),
        ),
      ),
    );
  }
}
