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

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _issueCtrl.dispose();
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
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: context.sp(40),
                            height: context.sp(40),
                            color: _kDark,
                            child: Icon(Icons.arrow_back,
                                color: Colors.white, size: context.sp(20)),
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
                    child: state.activeTab == ReportIssueTab.request
                        ? _RequestContent(
                            state: state,
                            cubit: cubit,
                            reasonCtrl: _reasonCtrl,
                          )
                        : _IssueContent(
                            state: state,
                            cubit: cubit,
                            issueCtrl: _issueCtrl,
                          ),
                  ),
                ),

                // ── Error ────────────────────────────────────────
                if (state.errorMessage.isNotEmpty)
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

                // ── Bottom Button ────────────────────────────────
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
                ),
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

  const _RequestContent({
    required this.state,
    required this.cubit,
    required this.reasonCtrl,
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

        SizedBox(height: context.sp(20)),

        Row(
          children: [
            Expanded(
              child: _DateField(
                label: l.startDate,
                date: state.startDate,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: state.startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
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
                  final d = await showDatePicker(
                    context: context,
                    initialDate: state.endDate ??
                        (state.startDate ?? DateTime.now()),
                    firstDate: state.startDate ?? DateTime(2020),
                    lastDate: DateTime(2030),
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
        height: context.sp(44),
        decoration: BoxDecoration(
          color: isSelected ? _kGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kGreen, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
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
