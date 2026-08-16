import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/profile_model.dart';

/// Greeting card — the greeting text tracks the app's Israel local time
/// (same source as the home screen's live clock row) and switches between
/// Morning / Afternoon / Evening / Night as the hour changes.
class GreetingCard extends StatefulWidget {
  const GreetingCard({super.key});

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  late final tz.Location _israel = tz.getLocation('Asia/Jerusalem');
  late int _hour = tz.TZDateTime.now(_israel).hour;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      final hour = tz.TZDateTime.now(_israel).hour;
      if (hour != _hour) setState(() => _hour = hour);
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _greeting(AppLocalizations l) {
    if (_hour >= 5 && _hour < 12) return l.goodMorning;
    if (_hour >= 12 && _hour < 17) return l.goodAfternoon;
    if (_hour >= 17 && _hour < 21) return l.goodEvening;
    return l.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final profile = ProfileModel.dummy;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF242F31),
        borderRadius: BorderRadius.circular(context.sp(8)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: context.sp(22),
            backgroundColor: const Color(0xFF354E48),
            child: Icon(
              Icons.person,
              size: context.sp(26),
              color: Colors.white,
            ),
          ),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(l),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFB0BAC5),
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: context.sp(1)),
                Text(
                  '${profile.surname} ${profile.otherName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: context.sp(19),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  profile.employeeNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFB0BAC5),
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
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
