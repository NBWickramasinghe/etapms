import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/locale/locale_cubit.dart';
import '../../../core/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/profile_model.dart';
import '../../change_password/change_password_screen.dart';
import '../../language/language_screen.dart';
import '../../login/login_screen.dart';
import '../../profile/profile_screen.dart';
import '../../report_issue/report_issue_screen.dart';

const _kDark = Color(0xFF242F31);
const _kText = Color(0xFF191C21);
const _kRed  = Color(0xFFBF3847);

String _localeName(String code) {
  switch (code) {
    case 'ar': return 'العربية';
    case 'si': return 'සිංහල';
    case 'hi': return 'हिन्दी';
    case 'zh': return '中文';
    case 'ru': return 'Русский';
    case 'th': return 'ไทย';
    default:   return 'English';
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Drawer(
      width: context.wp(82),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(20),
                context.sp(16),
                context.sp(16),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: context.sp(30),
                      backgroundColor: const Color(0xFF354E48),
                      child: Icon(
                        Icons.person,
                        size: context.sp(34),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: context.sp(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ProfileModel.dummy.surname} ${ProfileModel.dummy.otherName}',
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(17),
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            letterSpacing: 0,
                            color: _kText,
                          ),
                        ),
                        SizedBox(height: context.sp(3)),
                        Text(
                          ProfileModel.dummy.employeeNo,
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                            letterSpacing: 0,
                            color: _kDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Scaffold.of(context).closeDrawer(),
                    child: Padding(
                      padding: EdgeInsets.all(context.sp(6)),
                      child: Icon(Icons.close, size: context.sp(22), color: _kDark),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
            SizedBox(height: context.sp(8)),

            // ── Menu items ────────────────────────────────────────
            _DrawerItem(
              icon: Icons.person,
              label: l.myProfile,
              onTap: () {
                Scaffold.of(context).closeDrawer();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.info,
              label: l.requestIssue,
              onTap: () {
                Scaffold.of(context).closeDrawer();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.lock,
              label: l.changePassword,
              onTap: () {
                Scaffold.of(context).closeDrawer();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),

            // Language item — subtitle shows currently active language
            BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return _DrawerItem(
                  icon: Icons.language,
                  label: l.language,
                  subtitle: _localeName(locale.languageCode),
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LanguageScreen()),
                    );
                  },
                );
              },
            ),

            const Spacer(),

            // ── Logout ────────────────────────────────────────────
            Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
            SizedBox(height: context.sp(4)),

            _DrawerItem(
              icon: Icons.logout,
              label: l.logout,
              isLogout: true,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),

            SizedBox(height: context.sp(16)),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isLogout;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLogout ? _kRed : _kDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
            vertical: context.sp(13),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: context.sp(22)),
              SizedBox(width: context.sp(18)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: 0,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: context.sp(2)),
                    Text(
                      subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        letterSpacing: 0,
                        color: _kText.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
