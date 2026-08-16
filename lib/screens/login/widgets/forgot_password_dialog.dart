import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/forgot_password/forgot_password_cubit.dart';
import '../../../bloc/forgot_password/forgot_password_state.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';

const _kDark = Color(0xFF242F31);
const _kBg = Color(0xFFF5F0E8);
const _kRed = Color(0xFFBF3847);
const _kGreen = Color(0xFF354E48);

/// Shows the "Forgot Password?" dialog — the user enters their Worker /
/// Employee ID and requests a password reset. The actual reset request is
/// a dummy delay for now — API integration point, see [ForgotPasswordCubit].
Future<void> showForgotPasswordDialog(BuildContext context) {
  return showGeneralDialog<void>(
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
    pageBuilder: (context, _, _) => BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: const _ForgotPasswordDialogPage(),
    ),
  );
}

class _ForgotPasswordDialogPage extends StatelessWidget {
  const _ForgotPasswordDialogPage();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: const Center(
          child: _DialogContent(),
        ),
      ),
    );
  }
}

class _DialogContent extends StatefulWidget {
  const _DialogContent();

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  final _employeeIdCtrl = TextEditingController();

  @override
  void dispose() {
    _employeeIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screen = MediaQuery.sizeOf(context);
    // Cap the card so it never sprawls edge-to-edge in landscape, and cap
    // its height so it always fits short landscape viewports — the body
    // scrolls internally instead of overflowing the screen.
    final maxWidth = math.min(420.0, screen.width * 0.88);
    final maxHeight = screen.height * 0.85;

    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l.passwordResetRequested,
                style: GoogleFonts.poppins(fontSize: context.sp(13)),
              ),
              backgroundColor: _kGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ForgotPasswordStatus.loading;

        return ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.sp(14)),
            ),
            // showGeneralDialog doesn't wrap its content in a Material
            // ancestor the way showDialog does — TextField (and InkWell)
            // need one, so provide it here without painting anything of
            // its own (the white background above already handles that).
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(context.sp(14)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        context.sp(20),
                        context.sp(22),
                        context.sp(20),
                        context.sp(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title + close button ────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l.forgotPassword,
                                  style: GoogleFonts.poppins(
                                    fontSize: context.sp(17),
                                    fontWeight: FontWeight.w700,
                                    color: _kDark,
                                    letterSpacing: 0,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => Navigator.of(context).pop(),
                                child: Padding(
                                  padding: EdgeInsets.all(context.sp(4)),
                                  child: Icon(
                                    Icons.close,
                                    size: context.sp(20),
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: context.sp(8)),

                          Text(
                            l.forgotPasswordMessage,
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w400,
                              color: _kDark.withValues(alpha: 0.65),
                              height: 1.4,
                              letterSpacing: 0,
                              decoration: TextDecoration.none,
                            ),
                          ),

                          SizedBox(height: context.sp(20)),

                          // ── Employee ID field ────────────────────
                          Container(
                            height: context.sp(54),
                            decoration: BoxDecoration(
                              color: _kBg,
                              borderRadius:
                                  BorderRadius.circular(context.sp(12)),
                              border: Border.all(
                                color: _kDark.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: context.sp(16)),
                                Icon(
                                  Icons.badge_outlined,
                                  color: _kDark,
                                  size: context.sp(20),
                                ),
                                SizedBox(width: context.sp(10)),
                                Expanded(
                                  child: TextField(
                                    controller: _employeeIdCtrl,
                                    enabled: !isLoading,
                                    style: GoogleFonts.poppins(
                                      fontSize: context.sp(13),
                                      color: _kDark,
                                      letterSpacing: 0,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: l.enterEmployeeId,
                                      hintStyle: GoogleFonts.poppins(
                                        color:
                                            _kDark.withValues(alpha: 0.4),
                                        fontSize: context.sp(13),
                                        letterSpacing: 0,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                SizedBox(width: context.sp(14)),
                              ],
                            ),
                          ),

                          if (state.status ==
                                  ForgotPasswordStatus.failure &&
                              state.errorMessage.isNotEmpty) ...[
                            SizedBox(height: context.sp(10)),
                            Text(
                              state.errorMessage,
                              style: GoogleFonts.poppins(
                                fontSize: context.sp(12),
                                color: _kRed,
                                letterSpacing: 0,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Request button ──────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.sp(20),
                      context.sp(8),
                      context.sp(20),
                      context.sp(20),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: context.sp(50),
                      child: Material(
                        color: _kDark,
                        borderRadius: BorderRadius.circular(context.sp(12)),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(context.sp(12)),
                          onTap: isLoading
                              ? null
                              : () => context
                                  .read<ForgotPasswordCubit>()
                                  .submit(_employeeIdCtrl.text),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    l.requestPasswordReset,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: context.sp(14),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
