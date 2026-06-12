import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../bloc/home/home_bloc.dart';
import '../../../bloc/home/home_event.dart';
import '../../../bloc/home/home_state.dart';
import '../../../core/responsive.dart';
import '../../../models/log_entry.dart';

const _kDark  = Color(0xFF242F31);
const _kGreen = Color(0xFF354E48);
const _kRed   = Color(0xFFBF3847);
const _kAmber = Color(0xFFD4882A);

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final today = DateTime.now();
        final todayNorm = DateTime(today.year, today.month, today.day);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(4)),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: context.sp(32),
                  minHeight: context.sp(32),
                ),
                icon: Icon(Icons.chevron_left,
                    color: _kDark, size: context.sp(22)),
                onPressed: () => context
                    .read<HomeBloc>()
                    .add(const HomeWeekNavigated(-1)),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final date =
                        state.weekStart.add(Duration(days: i));
                    final dateNorm =
                        DateTime(date.year, date.month, date.day);
                    final isSelected =
                        dateNorm == DateTime(
                          state.selectedDate.year,
                          state.selectedDate.month,
                          state.selectedDate.day,
                        );
                    final isToday = dateNorm == todayNorm;
                    final isPast = dateNorm.isBefore(todayNorm);
                    final status =
                        state.attendanceMap[dateNorm];

                    return _DayItem(
                      date: date,
                      isSelected: isSelected,
                      isToday: isToday,
                      isPast: isPast,
                      attendanceStatus: status,
                      onTap: () => context
                          .read<HomeBloc>()
                          .add(HomeDateSelected(date)),
                    );
                  }),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: context.sp(32),
                  minHeight: context.sp(32),
                ),
                icon: Icon(Icons.chevron_right,
                    color: _kDark, size: context.sp(22)),
                onPressed: () => context
                    .read<HomeBloc>()
                    .add(const HomeWeekNavigated(1)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Day item ──────────────────────────────────────────────────────────────────

class _DayItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isPast;
  final LogStatus? attendanceStatus;
  final VoidCallback onTap;

  const _DayItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isPast,
    required this.attendanceStatus,
    required this.onTap,
  });

  // Colour for each attendance status
  Color get _statusColor => switch (attendanceStatus) {
        LogStatus.present      => _kGreen,
        LogStatus.absence      => _kRed,
        LogStatus.publicHoliday => _kAmber,
        null                   => Colors.transparent,
      };

  // Whether to show the attendance circle (past days with data, not selected)
  bool get _showAttendance =>
      isPast && attendanceStatus != null && !isSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dayLabel = DateFormat('E', locale).format(date);

    // Day name colour
    final dayNameColor = isSelected
        ? Colors.white
        : _kDark.withValues(alpha: 0.45);

    // Day number colour
    final dayNumColor = isSelected || _showAttendance
        ? Colors.white
        : _kDark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: context.sp(38),
        padding: EdgeInsets.symmetric(vertical: context.sp(10)),
        decoration: BoxDecoration(
          // Oval background — only for selected/today
          color: isSelected ? _kDark : Colors.transparent,
          borderRadius: BorderRadius.circular(context.sp(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Day abbreviation ─────────────────────────────
            Text(
              dayLabel,
              style: GoogleFonts.poppins(
                color: dayNameColor,
                fontSize: context.sp(9.5),
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),

            SizedBox(height: context.sp(5)),

            // ── Day number — plain text inside optional circle ─
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: context.sp(26),
              height: context.sp(26),
              decoration: BoxDecoration(
                // Attendance circle for past days (selected oval takes priority)
                color: _showAttendance
                    ? _statusColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: GoogleFonts.poppins(
                    color: dayNumColor,
                    fontSize: context.sp(13),
                    fontWeight: isSelected || _showAttendance
                        ? FontWeight.w700
                        : FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),

            SizedBox(height: context.sp(4)),

            // ── Today dot ─────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: context.sp(4),
              height: context.sp(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday
                    ? (isSelected ? Colors.white : _kRed)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
