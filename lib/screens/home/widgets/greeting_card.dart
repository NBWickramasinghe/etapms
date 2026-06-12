import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.goodMorning,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFB0BAC5),
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: context.sp(1)),
              Text(
                'Dulaj',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: context.sp(19),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              Text(
                'HR Manager',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFB0BAC5),
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w400,
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
