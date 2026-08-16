import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/login/login_bloc.dart';
import '../../bloc/login/login_event.dart';
import '../../bloc/login/login_state.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../app.dart';
import 'widgets/forgot_password_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AppShell()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.sp(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.hp(10)),

                // Title
                Text(
                  l.employeeLogging,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(24),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191C21),
                    letterSpacing: 0,
                  ),
                ),

                SizedBox(height: context.sp(32)),

                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: context.wp(52),
                ),

                SizedBox(height: context.sp(36)),

                // Employee ID field
                _InputField(
                  controller: _employeeIdController,
                  hint: l.enterEmployeeId,
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.text,
                ),

                SizedBox(height: context.sp(14)),

                // Password field
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return _InputField(
                      controller: _passwordController,
                      hint: l.enterPassword,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: state.isPasswordVisible,
                      onToggleVisibility: () => context
                          .read<LoginBloc>()
                          .add(const LoginPasswordVisibilityToggled()),
                    );
                  },
                ),

                SizedBox(height: context.sp(14)),

                // Remember me
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        SizedBox(
                          width: context.sp(22),
                          height: context.sp(22),
                          child: Checkbox(
                            value: state.rememberMe,
                            onChanged: (_) => context
                                .read<LoginBloc>()
                                .add(const LoginRememberMeToggled()),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: Colors.black54,
                              width: context.sp(1.5),
                            ),
                            activeColor: const Color(0xFF354E48),
                          ),
                        ),
                        SizedBox(width: context.sp(10)),
                        Expanded(
                          child: Text(
                            l.rememberMe,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF191C21),
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        SizedBox(width: context.sp(8)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => showForgotPasswordDialog(context),
                          child: Text(
                            l.forgotPassword,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF354E48),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF354E48),
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: context.sp(28)),

                // Error message
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (prev, curr) =>
                      prev.errorMessage != curr.errorMessage,
                  builder: (context, state) {
                    if (state.errorMessage == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: context.sp(12)),
                      child: Text(
                        state.errorMessage!,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFBF3847),
                          fontSize: context.sp(13),
                          letterSpacing: 0,
                        ),
                      ),
                    );
                  },
                ),

                // Log In button
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final isLoading = state.status == LoginStatus.loading;
                    return SizedBox(
                      width: double.infinity,
                      height: context.sp(56),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFF242F31),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () => context.read<LoginBloc>().add(
                                      LoginSubmitted(
                                        employeeId:
                                            _employeeIdController.text,
                                        password: _passwordController.text,
                                      ),
                                    ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      l.logIn,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: context.sp(17),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: context.hp(12)),

                // Footer
                Text(
                  '@ Developed by NB Code',
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(13),
                    color: Colors.black38,
                    letterSpacing: 0,
                  ),
                ),

                SizedBox(height: context.sp(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.sp(58),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(context.sp(14)),
        border: Border.all(
          color: const Color(0xFF242F31).withValues(alpha: 0.45),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: context.sp(18)),
          Icon(icon, color: const Color(0xFF242F31), size: context.sp(22)),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword && !isPasswordVisible,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: context.sp(14),
                color: const Color(0xFF242F31),
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF242F31).withValues(alpha: 0.4),
                  fontSize: context.sp(14),
                  letterSpacing: 0,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isPassword)
            GestureDetector(
              onTap: onToggleVisibility,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: context.sp(14)),
                child: Icon(
                  isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF354E48),
                  size: context.sp(20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
