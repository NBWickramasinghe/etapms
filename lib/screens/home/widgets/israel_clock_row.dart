import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../core/responsive.dart';

/// Live date/time display pinned to Israel local time (Asia/Jerusalem),
/// including DST — ticks every second for as long as it's mounted.
class IsraelClockRow extends StatefulWidget {
  const IsraelClockRow({super.key});

  @override
  State<IsraelClockRow> createState() => _IsraelClockRowState();
}

class _IsraelClockRowState extends State<IsraelClockRow> {
  late final tz.Location _israel = tz.getLocation('Asia/Jerusalem');
  late tz.TZDateTime _now = tz.TZDateTime.now(_israel);
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = tz.TZDateTime.now(_israel));
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('M.d.yyyy').format(_now);
    final timeStr = DateFormat('hh.mm a').format(_now);
    final style = GoogleFonts.poppins(
      fontSize: context.sp(13),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF191C21),
      letterSpacing: 0,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
      child: Row(
        children: [
          Text(dateStr, style: style),
          const Spacer(),
          Text(timeStr, style: style),
        ],
      ),
    );
  }
}
