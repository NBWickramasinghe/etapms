import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/location/location_cubit.dart';
import '../../../bloc/location/location_state.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';
import 'live_location_map.dart';

const _kAsh = Color(0xFFB0BAC5);
const _kRed = Color(0xFFBF3847);
const _kBg = Color(0xFF242F31);

class InfoCardsPanel extends StatelessWidget {
  const InfoCardsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationCubit(),
      child: Container(
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(context.sp(8)),
        ),
        child: Column(
          children: [
            _LocationSection(),
            _Divider(),
            _StatsSection(),
            _Divider(),
            _CurrentLocationSection(),
          ],
        ),
      ),
    );
  }
}

// ── Section: Working Location ─────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(10),
      ),
      child: Row(
        children: [
          _RedIcon(Icons.location_on),
          SizedBox(width: context.sp(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zikim',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              Text(
                'Public Transport',
                style: GoogleFonts.poppins(
                  color: _kAsh,
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Thu Jan',
                style: GoogleFonts.poppins(
                  color: _kAsh,
                  fontSize: context.sp(9),
                  letterSpacing: 0,
                ),
              ),
              Text(
                '08',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: context.sp(29),
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section: Stats 2×2 ────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(10)),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.today,
                    value: '22',
                    label: l.workDays,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.do_not_disturb_on,
                    value: '02',
                    label: l.absenceDays,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
            child: Divider(
              color: _kAsh.withValues(alpha: 0.18),
              height: context.sp(16),
              thickness: 1,
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.celebration,
                    value: '01',
                    label: l.publicHolidays,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.watch_later,
                    value: '160h',
                    label: l.workHours,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: context.sp(25),
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: context.sp(6)),
              Transform.translate(
                offset: Offset(0, -context.sp(4)),
                child: Icon(icon, color: _kRed, size: context.sp(17)),
              ),
            ],
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: _kAsh,
              fontSize: context.sp(8.5),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: _kAsh.withValues(alpha: 0.18),
    );
  }
}

// ── Section: Current Location ─────────────────────────────────────────────────

class _CurrentLocationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(10),
      ),
      child: Row(
        children: [
          _RedIcon(Icons.my_location),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.currentLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    final text = switch (state.status) {
                      LocationStatus.ready =>
                        state.placeName ?? l.locating,
                      LocationStatus.loading => l.locating,
                      LocationStatus.denied ||
                      LocationStatus.disabled ||
                      LocationStatus.error =>
                        l.locationUnavailable,
                    };
                    return Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _kAsh,
                        fontSize: context.sp(10),
                        letterSpacing: 0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: context.sp(8)),
          SizedBox(
            width: context.sp(62),
            height: context.sp(52),
            child: const LiveLocationMap(),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _RedIcon extends StatelessWidget {
  final IconData icon;

  const _RedIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: _kRed, size: context.sp(22));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: _kAsh.withValues(alpha: 0.18),
      height: 1,
      thickness: 1,
    );
  }
}
