import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/log_entry.dart';

const _kDark = Color(0xFF242F31);
const _kGreen = Color(0xFF354E48);
const _kRed = Color(0xFFBF3847);
const _kText = Color(0xFF191C21);
const _kAmber = Color(0xFFD4882A);

class RecentLogList extends StatelessWidget {
  final List<LogEntry> logs;

  const RecentLogList({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < logs.length; i++) _LogRow(log: logs[i], index: i),
      ],
    );
  }
}

// ── Log row — mirrors the History screen's numbered-list theme ──────────────

class _LogRow extends StatelessWidget {
  final LogEntry log;
  final int index;

  const _LogRow({required this.log, required this.index});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final l = AppLocalizations.of(context)!;
    final dateStr = DateFormat('yyyy MMM dd', locale).format(log.date);
    final hasTime = log.startTime != null && log.endTime != null;

    final (statusLabel, statusColor) = switch (log.status) {
      LogStatus.present => (l.present, _kGreen),
      LogStatus.absence => (l.absence, _kRed),
      LogStatus.publicHoliday => (l.publicHoliday, _kAmber),
    };

    final numStr = (index + 1).toString().padLeft(2, '0');

    return Padding(
      // generous spacing between rows — key to the reference look
      padding: EdgeInsets.only(
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
