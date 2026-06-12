import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';

Future<bool?> showStartWorkDialog(BuildContext context) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
    pageBuilder: (context, _, _) => const _StartWorkDialogPage(),
  );
}

class _StartWorkDialogPage extends StatelessWidget {
  const _StartWorkDialogPage();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Center(
          child: _DialogContent(),
        ),
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.sp(44)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.sp(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.sp(20),
              context.sp(28),
              context.sp(20),
              context.sp(12),
            ),
            child: Text(
              l.startWork,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: context.sp(16),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF191C21),
                letterSpacing: 0,
                decoration: TextDecoration.none,
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
            child: Text(
              l.startWorkMessage,
              style: GoogleFonts.poppins(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF242F31),
                height: 1.5,
                letterSpacing: 0,
                decoration: TextDecoration.none,
              ),
            ),
          ),

          SizedBox(height: context.sp(28)),

          // ── Divider ────────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // ── Buttons ────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.sp(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(context.sp(14)),
                        ),
                      ),
                    ),
                    child: Text(
                      l.no,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF242F31),
                        letterSpacing: 0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.sp(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(context.sp(14)),
                        ),
                      ),
                    ),
                    child: Text(
                      l.yes,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF242F31),
                        letterSpacing: 0,
                        decoration: TextDecoration.none,
                      ),
                    ),
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
