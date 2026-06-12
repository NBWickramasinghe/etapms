import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../bloc/history/history_cubit.dart';
import '../../bloc/history/history_state.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';

const _kDark   = Color(0xFF242F31);
const _kGreen  = Color(0xFF354E48);
const _kRed    = Color(0xFFBF3847);
const _kText   = Color(0xFF191C21);
const _kBg     = Color(0xFFF5F0E8);
const _kAmber  = Color(0xFFD4882A);

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final cubit = context.read<HistoryCubit>();
        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.sp(20), context.sp(20),
                    context.sp(20), context.sp(4),
                  ),
                  child: Text(
                    l.history,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(22),
                      fontWeight: FontWeight.w700,
                      color: _kText,
                      letterSpacing: 0,
                    ),
                  ),
                ),

                // ── Filter row ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(20),
                    vertical: context.sp(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: l.startDate,
                          date: state.startDate,
                          onTap: () => _pickDate(
                            context,
                            initial: state.startDate,
                            onPicked: cubit.selectStartDate,
                          ),
                        ),
                      ),
                      SizedBox(width: context.sp(8)),
                      Expanded(
                        child: _DateField(
                          label: l.endDate,
                          date: state.endDate,
                          onTap: () => _pickDate(
                            context,
                            initial: state.endDate ??
                                state.startDate ?? DateTime.now(),
                            firstDate: state.startDate,
                            onPicked: cubit.selectEndDate,
                          ),
                        ),
                      ),
                      SizedBox(width: context.sp(8)),
                      _FilterButton(
                        enabled: state.canFilter,
                        isLoading: state.isLoading,
                        onTap: cubit.applyFilter,
                      ),
                    ],
                  ),
                ),

                // ── Section header (HOW-TO-USE style) ──────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.sp(20), 0,
                    context.sp(20), 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'ATTENDANCE',
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(10.5),
                              fontWeight: FontWeight.w600,
                              color: _kDark.withValues(alpha: 0.50),
                              letterSpacing: 1.8,
                            ),
                          ),
                          Text(
                            _periodLabel(state),
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(10.5),
                              fontWeight: FontWeight.w600,
                              color: _kDark.withValues(alpha: 0.50),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.sp(8)),
                      Divider(
                        height: 1, thickness: 1,
                        color: _kDark.withValues(alpha: 0.18),
                      ),
                      SizedBox(height: context.sp(4)),
                    ],
                  ),
                ),

                // ── Log list ────────────────────────────────────
                Expanded(
                  child: state.logs.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: context.sp(24)),
                          itemCount: state.logs.length,
                          itemBuilder: (_, i) =>
                              _LogCard(log: state.logs[i], index: i),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _periodLabel(HistoryState state) {
    if (state.startDate != null && state.endDate != null) {
      final fmt = DateFormat('MMM yyyy');
      if (state.startDate!.month == state.endDate!.month &&
          state.startDate!.year == state.endDate!.year) {
        return fmt.format(state.startDate!);
      }
      return '${DateFormat('MMM').format(state.startDate!)} – '
          '${fmt.format(state.endDate!)}';
    }
    return DateFormat('MMM yyyy').format(DateTime.now());
  }

  Future<void> _pickDate(
    BuildContext context, {
    DateTime? initial,
    DateTime? firstDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kGreen,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }
}

// ── Date field (dropdown-style) ───────────────────────────────────────────────

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
    final locale = Localizations.localeOf(context).languageCode;
    final hasDate = date != null;
    final display = hasDate
        ? DateFormat('dd MMM yyyy', locale).format(date!)
        : label;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: context.sp(48),
        padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
        color: _kDark,
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(12),
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                  color: hasDate
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withValues(alpha: 0.7),
              size: context.sp(18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter button ─────────────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _FilterButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: context.sp(48),
        padding: EdgeInsets.symmetric(horizontal: context.sp(14)),
        color: enabled ? _kGreen : _kGreen.withValues(alpha: 0.4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: context.sp(16),
                height: context.sp(16),
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            else
              Icon(Icons.tune, color: Colors.white, size: context.sp(16)),
            SizedBox(width: context.sp(6)),
            Text(
              'Filter',
              style: GoogleFonts.poppins(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Log row (numbered text style — like the reference image) ─────────────────

class _LogCard extends StatelessWidget {
  final LogEntry log;
  final int index;

  const _LogCard({required this.log, required this.index});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final l = AppLocalizations.of(context)!;
    final dateStr = DateFormat('yyyy MMM dd', locale).format(log.date);
    final hasTime = log.startTime != null && log.endTime != null;

    final (statusLabel, statusColor) = switch (log.status) {
      LogStatus.present      => (l.present,      _kGreen),
      LogStatus.absence      => (l.absence,       _kRed),
      LogStatus.publicHoliday => (l.publicHoliday, _kAmber),
    };

    final numStr = (index + 1).toString().padLeft(2, '0');

    return Padding(
      // generous spacing between rows — key to the reference look
      padding: EdgeInsets.only(
        left: context.sp(20),
        right: context.sp(20),
        top: context.sp(16),
        bottom: context.sp(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Number  —  (fixed-width column) ───────────────
          SizedBox(
            width: context.sp(40),
            child: Text(
              '$numStr  —',
              style: GoogleFonts.poppins(
                fontSize: context.sp(12.5),
                fontWeight: FontWeight.w600,
                color: _kDark.withValues(alpha: 0.40),
                letterSpacing: 0,
              ),
            ),
          ),

          SizedBox(width: context.sp(6)),

          // ── Content ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: date  Status  Location
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$dateStr  ',
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(12.5),
                          fontWeight: FontWeight.w500,
                          color: _kText,
                        ),
                      ),
                      TextSpan(
                        text: statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(12.5),
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      if (log.location.isNotEmpty)
                        TextSpan(
                          text: '  ${log.location}',
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(12.5),
                            fontWeight: FontWeight.w600,
                            color: _kDark,
                          ),
                        ),
                    ],
                  ),
                ),

                // Line 2: time range (present only)
                if (hasTime) ...[
                  SizedBox(height: context.sp(5)),
                  Text(
                    'Start time ${log.startTime}  -  End time ${log.endTime}',
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(11.5),
                      fontWeight: FontWeight.w400,
                      color: _kText.withValues(alpha: 0.45),
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off,
              size: context.sp(56),
              color: _kDark.withValues(alpha: 0.15)),
          SizedBox(height: context.sp(14)),
          Text(
            'No records found',
            style: GoogleFonts.poppins(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w500,
              color: _kText.withValues(alpha: 0.35),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
