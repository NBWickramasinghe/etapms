import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/change_password/change_password_cubit.dart';
import '../../bloc/change_password/change_password_state.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';

const _kDark  = Color(0xFF242F31);
const _kText  = Color(0xFF191C21);
const _kGreen = Color(0xFF354E48);
const _kRed   = Color(0xFFBF3847);
const _kBg    = Color(0xFFF5F0E8);

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == ChangePasswordStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l.passwordChangedSuccess,
                style: GoogleFonts.poppins(fontSize: context.sp(13)),
              ),
              backgroundColor: _kGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final cubit = context.read<ChangePasswordCubit>();

        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.sp(14)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: context.sp(40),
                              height: context.sp(40),
                              color: _kDark,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: context.sp(20),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          l.changePassword,
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(19),
                            fontWeight: FontWeight.w700,
                            color: _kText,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.sp(6)),

                  // ── Subtitle ────────────────────────────────────
                  Text(
                    l.changePasswordSubtitle,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w600,
                      color: _kText,
                      letterSpacing: 0,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: context.sp(24)),

                  // ── Current Password ────────────────────────────
                  _PasswordField(
                    controller: _currentCtrl,
                    label: l.currentPassword,
                    hint: l.enterCurrentPassword,
                    isVisible: state.currentVisible,
                    onToggle: cubit.toggleCurrentVisibility,
                  ),

                  SizedBox(height: context.sp(12)),

                  // ── New Password ────────────────────────────────
                  _PasswordField(
                    controller: _newCtrl,
                    label: l.newPassword,
                    hint: l.enterNewPassword,
                    isVisible: state.newVisible,
                    onToggle: cubit.toggleNewVisibility,
                    onChanged: cubit.updateNewPassword,
                  ),

                  if (state.newPassword.isNotEmpty) ...[
                    SizedBox(height: context.sp(10)),
                    _StrengthBar(strength: state.strength),
                  ],

                  SizedBox(height: context.sp(12)),

                  // ── Confirm Password ────────────────────────────
                  _PasswordField(
                    controller: _confirmCtrl,
                    label: l.confirmNewPassword,
                    hint: l.confirmNewPassword,
                    isVisible: state.confirmVisible,
                    onToggle: cubit.toggleConfirmVisibility,
                  ),

                  SizedBox(height: context.sp(20)),

                  // ── Requirements ────────────────────────────────
                  _Requirements(),

                  SizedBox(height: context.sp(12)),

                  // ── Error message ───────────────────────────────
                  if (state.errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: context.sp(8)),
                      child: Text(
                        state.errorMessage,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(12),
                          color: _kRed,
                          letterSpacing: 0,
                        ),
                      ),
                    ),

                  // ── Button ──────────────────────────────────────
                  _ChangePasswordButton(
                    isLoading: state.status == ChangePasswordStatus.loading,
                    onTap: () => cubit.submit(
                      _currentCtrl.text.trim(),
                      _newCtrl.text.trim(),
                      _confirmCtrl.text.trim(),
                    ),
                  ),

                  SizedBox(height: context.sp(24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isVisible;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isVisible,
    required this.onToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: context.sp(6)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(16),
            vertical: context.sp(14),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _kGreen.withValues(alpha: 0.35),
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, size: context.sp(19), color: _kDark),
              SizedBox(width: context.sp(14)),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: !isVisible,
                  onChanged: onChanged,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w400,
                    color: _kText,
                    letterSpacing: 0,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w400,
                      color: _kText.withValues(alpha: 0.35),
                      letterSpacing: 0,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onToggle,
                child: Padding(
                  padding: EdgeInsets.only(left: context.sp(8)),
                  child: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    size: context.sp(19),
                    color: _kDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final PasswordStrength strength;

  const _StrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fraction = switch (strength) {
      PasswordStrength.weak   => 0.33,
      PasswordStrength.medium => 0.66,
      PasswordStrength.strong => 1.0,
    };
    final barColor = switch (strength) {
      PasswordStrength.weak   => _kRed,
      PasswordStrength.medium => _kGreen,
      PasswordStrength.strong => _kText,
    };
    final label = switch (strength) {
      PasswordStrength.weak   => l.weak,
      PasswordStrength.medium => l.medium,
      PasswordStrength.strong => l.strong,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (ctx, constraints) => Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: context.sp(6),
                color: Colors.grey.shade300,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * fraction,
                height: context.sp(6),
                color: barColor,
              ),
            ],
          ),
        ),
        SizedBox(height: context.sp(4)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: context.sp(11),
            fontWeight: FontWeight.w600,
            color: barColor,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _Requirements extends StatelessWidget {
  const _Requirements();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final itemStyle = GoogleFonts.poppins(
      fontSize: context.sp(12),
      fontWeight: FontWeight.w400,
      color: _kText,
      letterSpacing: 0,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.passwordMustContain,
          style: GoogleFonts.poppins(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: _kText,
            letterSpacing: 0,
          ),
        ),
        Text('• ${l.passwordChars}', style: itemStyle),
        Text('• ${l.passwordUppercase}', style: itemStyle),
        Text('• ${l.passwordNumber}', style: itemStyle),
      ],
    );
  }
}

class _ChangePasswordButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _ChangePasswordButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: context.sp(50),
        color: _kDark,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: context.sp(22),
                  height: context.sp(22),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  l.changePassword,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                ),
        ),
      ),
    );
  }
}
