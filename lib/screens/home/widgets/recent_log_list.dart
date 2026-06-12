import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/log_entry.dart';

class RecentLogList extends StatelessWidget {
  final List<LogEntry> logs;

  const RecentLogList({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < logs.length; i++) ...[
          _LogRow(log: logs[i]),
          Divider(
            color: Colors.grey.shade300,
            thickness: 0.8,
            height: 1,
          ),
        ],
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  final LogEntry log;

  const _LogRow({required this.log});

  bool get _isAbsence => log.status == LogStatus.absence;

  Color get _primaryColor =>
      _isAbsence ? const Color(0xFFBF3847) : const Color(0xFF242F31);

  String _statusLabel(AppLocalizations l) {
    switch (log.status) {
      case LogStatus.present:
        return l.present;
      case LogStatus.absence:
        return l.absence;
      case LogStatus.publicHoliday:
        return l.publicHoliday;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final day = log.date.day.toString().padLeft(2, '0');
    final month = DateFormat('MMM', locale).format(log.date);
    final year = '${log.date.year}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(7)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Day number scaled to match the two-line right column ──
            FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.centerLeft,
              child: Text(
                day,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
            ),

            SizedBox(width: context.sp(8)),

            // ── Two aligned rows: [month | status+location] / [year | times] ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row 1: Jan   Present Zikim Camp
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: context.sp(28),
                        child: Text(
                          month,
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: context.sp(8)),
                      Expanded(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _statusLabel(l),
                                style: GoogleFonts.poppins(
                                  fontSize: context.sp(13),
                                  fontWeight: FontWeight.w700,
                                  color: _isAbsence
                                      ? const Color(0xFFBF3847)
                                      : const Color(0xFF191C21),
                                ),
                              ),
                              TextSpan(
                                text: '  ${log.location}',
                                style: GoogleFonts.poppins(
                                  fontSize: context.sp(12),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF242F31),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.sp(2)),

                  // Row 2: 2026  ▲ 07:00 AM  ▼ 05:00 PM
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: context.sp(28),
                        child: Text(
                          year,
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.w400,
                            color: _primaryColor.withValues(alpha: 0.55),
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: context.sp(8)),
                      if (log.startTime != null && log.endTime != null) ...[
                        _TimeTag(arrow: '▲', time: log.startTime!),
                        SizedBox(width: context.sp(12)),
                        _TimeTag(arrow: '▼', time: log.endTime!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTag extends StatelessWidget {
  final String arrow;
  final String time;

  const _TimeTag({required this.arrow, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          arrow,
          style: TextStyle(
            fontSize: context.sp(8),
            color: const Color(0xFF354E48),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(width: context.sp(3)),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: context.sp(11),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF242F31),
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
