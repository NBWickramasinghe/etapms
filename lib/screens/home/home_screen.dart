import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/greeting_card.dart';
import 'widgets/info_cards.dart';
import 'widgets/recent_log_list.dart';
import 'widgets/week_calendar.dart';
import 'widgets/start_work_dialog.dart';

const _kRed = Color(0xFFBF3847);
const _kDark = Color(0xFF242F31);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final monthYear = DateFormat('MMMM y', locale).format(state.selectedDate);

        return ColoredBox(
          color: const Color(0xFFF5F0E8),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hamburger + Greeting card (same row) ───────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.sp(8),
                    context.sp(6),
                    context.sp(16),
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Builder(
                        builder: (ctx) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Scaffold.of(ctx).openDrawer(),
                          child: SizedBox(
                            width: context.sp(44),
                            height: context.sp(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: context.sp(4),
                              children: [
                                _MenuLine(width: context.sp(22)),
                                _MenuLine(width: context.sp(16)),
                                _MenuLine(width: context.sp(22)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.sp(6)),
                      const Expanded(child: GreetingCard()),
                    ],
                  ),
                ),

                SizedBox(height: context.sp(8)),

                // ── Month / time row ────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            monthYear,
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF191C21),
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(width: context.sp(3)),
                          Icon(Icons.keyboard_arrow_down,
                              size: context.sp(17),
                              color: const Color(0xFF191C21)),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '07.00 PM',
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF191C21),
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.sp(4)),

                // ── Week calendar ───────────────────────────────────
                const WeekCalendar(),

                SizedBox(height: context.sp(8)),

                // ── Info cards (unified panel) ──────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
                  child: const InfoCardsPanel(),
                ),

                SizedBox(height: context.sp(10)),

                // ── Tracking row / Start button ─────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
                  child: state.isTracking
                      ? _TrackingRow(
                          elapsedSeconds: state.elapsedSeconds,
                          onStop: () => context
                              .read<HomeBloc>()
                              .add(const HomeTrackingToggled()),
                        )
                      : Center(
                          child: SizedBox(
                            width: context.wp(46),
                            height: context.sp(38),
                            child: DecoratedBox(
                              decoration:
                                  const BoxDecoration(color: _kDark),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    final confirmed =
                                        await showStartWorkDialog(context);
                                    if (confirmed == true &&
                                        context.mounted) {
                                      context.read<HomeBloc>().add(
                                          const HomeTrackingToggled());
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.timer_outlined,
                                          color: Colors.white,
                                          size: context.sp(16)),
                                      SizedBox(width: context.sp(6)),
                                      Text(
                                        l.start,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: context.sp(13),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                SizedBox(height: context.sp(12)),

                // ── Recently log header ───────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l.recentlyLog,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF191C21),
                          letterSpacing: 0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          l.viewAll,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF242F31),
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.sp(2)),

                // ── Log items ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
                  child: RecentLogList(logs: state.recentLogs),
                ),

                SizedBox(height: context.sp(10)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrackingRow extends StatelessWidget {
  final int elapsedSeconds;
  final VoidCallback onStop;

  const _TrackingRow({required this.elapsedSeconds, required this.onStop});

  String get _formatted {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    return '${h.toString().padLeft(2, '0')}h : ${m.toString().padLeft(2, '0')}m : ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      height: context.sp(58),
      padding: EdgeInsets.symmetric(horizontal: context.sp(14)),
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(context.sp(8)),
      ),
      child: Row(
        children: [
          // ── Timer icon + text ───────────────────────────────────
          Icon(Icons.timer, color: Colors.white, size: context.sp(22)),
          SizedBox(width: context.sp(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l.workingHours,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              Text(
                _formatted,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Stop button centered vertically inside card ─────────
          Center(
            child: DecoratedBox(
              decoration: const BoxDecoration(color: _kRed),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onStop,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.sp(14),
                      vertical: context.sp(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stop_rounded,
                            color: Colors.white, size: context.sp(16)),
                        SizedBox(width: context.sp(5)),
                        Text(
                          l.stop,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuLine extends StatelessWidget {
  final double width;

  const _MenuLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: context.sp(2),
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
