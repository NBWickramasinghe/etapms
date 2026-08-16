import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signature/signature.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';

const _kRed = Color(0xFFBF3847);
const _kDark = Color(0xFF242F31);

/// Shows the signature pad dialog. Resolves with the signed PNG bytes if the
/// user submits a signature, or `null` if the dialog is dismissed/closed
/// without signing.
Future<Uint8List?> showSignatureDialog(BuildContext context) {
  return showGeneralDialog<Uint8List?>(
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
    pageBuilder: (context, _, _) => const _SignatureDialogPage(),
  );
}

class _SignatureDialogPage extends StatelessWidget {
  const _SignatureDialogPage();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Center(
          child: _SignatureDialogContent(),
        ),
      ),
    );
  }
}

class _SignatureDialogContent extends StatefulWidget {
  @override
  State<_SignatureDialogContent> createState() =>
      _SignatureDialogContentState();
}

class _SignatureDialogContentState extends State<_SignatureDialogContent> {
  late final SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2.5,
      penColor: _kDark,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final bytes = await _controller.toPngBytes();
    if (mounted) Navigator.of(context).pop(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screen = MediaQuery.sizeOf(context);
    // Cap the card so it never sprawls edge-to-edge in landscape, and cap
    // its height so it always fits short landscape viewports. The pad
    // itself shrinks with the viewport instead of staying a fixed height
    // that could overflow the dialog.
    final maxWidth = math.min(460.0, screen.width * 0.9);
    final maxHeight = screen.height * 0.85;
    final padHeight = (screen.height * 0.24).clamp(110.0, 220.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.sp(14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header: title + close button ────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.sp(20),
                          context.sp(18),
                          context.sp(12),
                          0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.signature,
                                style: GoogleFonts.poppins(
                                  fontSize: context.sp(16),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF191C21),
                                  letterSpacing: 0,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.of(context).pop(),
                              child: Padding(
                                padding: EdgeInsets.all(context.sp(6)),
                                child: Icon(
                                  Icons.close,
                                  size: context.sp(20),
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: context.sp(4)),

                      // ── Instruction text ─────────────────────────
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: context.sp(20)),
                        child: Text(
                          l.signHere,
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF242F31),
                            height: 1.4,
                            letterSpacing: 0,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),

                      SizedBox(height: context.sp(14)),

                      // ── Signature pad ──────────────────────────
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: context.sp(20)),
                        child: Container(
                          height: padHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0E8),
                            borderRadius:
                                BorderRadius.circular(context.sp(10)),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Signature(
                            controller: _controller,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),

                      SizedBox(height: context.sp(20)),
                    ],
                  ),
                ),
              ),

              // ── Divider ────────────────────────────────────────
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

              // ── Buttons ────────────────────────────────────────
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _controller.clear(),
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: context.sp(14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(context.sp(14)),
                            ),
                          ),
                        ),
                        child: Text(
                          l.clear,
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.w600,
                            color: _kRed,
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
                        onPressed: _submit,
                        style: TextButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: context.sp(14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(context.sp(14)),
                            ),
                          ),
                        ),
                        child: Text(
                          l.submit,
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.w700,
                            color: _kDark,
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
        ),
      ),
    );
  }
}
