import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';

const _kDark = Color(0xFF242F31);
const _kGreen = Color(0xFF354E48);
const _kText = Color(0xFF191C21);
const _kBg = Color(0xFFF5F0E8);
const _kWhatsApp = Color(0xFF25D366);

class _SupportContact {
  final String name;
  final String position;
  final String phone;

  const _SupportContact({
    required this.name,
    required this.position,
    required this.phone,
  });
}

// Dummy support contacts — API integration point — replace with the real
// support directory fetched from the backend.
const _dummyContacts = <_SupportContact>[
  _SupportContact(
    name: 'Eitan Cohen',
    position: 'HR Support',
    phone: '+972 50-123-4567',
  ),
  _SupportContact(
    name: 'Noa Levi',
    position: 'IT Support',
    phone: '+972 52-234-5678',
  ),
  _SupportContact(
    name: 'Avi Mizrahi',
    position: 'Admin Support',
    phone: '+972 54-345-6789',
  ),
];

Future<void> _launchWhatsApp(BuildContext context, String phone) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  await _launch(context, Uri.parse('https://wa.me/$digits'));
}

Future<void> _launchDialer(BuildContext context, String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
  await _launch(context, Uri(scheme: 'tel', path: cleaned));
}

Future<void> _launch(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Couldn't open ${uri.scheme == 'tel' ? 'dialer' : 'WhatsApp'}",
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: _kDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(20),
                context.sp(20),
                context.sp(4),
              ),
              child: Text(
                l.support,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(22),
                  fontWeight: FontWeight.w700,
                  color: _kText,
                  letterSpacing: 0,
                ),
              ),
            ),

            SizedBox(height: context.sp(12)),

            // ── Contact list ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final contact in _dummyContacts) ...[
                      _ContactCard(contact: contact),
                      SizedBox(height: context.sp(14)),
                    ],
                    SizedBox(height: context.sp(8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final _SupportContact contact;

  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.sp(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _kGreen.withValues(alpha: 0.35),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + name + position ─────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: context.sp(22),
                backgroundColor: _kGreen,
                child: Icon(
                  Icons.person,
                  size: context.sp(24),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: context.sp(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w700,
                        color: _kText,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: context.sp(2)),
                    Text(
                      contact.position,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w400,
                        color: _kText.withValues(alpha: 0.55),
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: context.sp(14)),

          // ── WhatsApp + Call buttons ───────────────────────
          Row(
            children: [
              Expanded(
                child: _ContactActionButton(
                  icon: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: context.sp(15),
                    color: Colors.white,
                  ),
                  label: contact.phone,
                  color: _kWhatsApp,
                  onTap: () => _launchWhatsApp(context, contact.phone),
                ),
              ),
              SizedBox(width: context.sp(10)),
              Expanded(
                child: _ContactActionButton(
                  icon: Icon(
                    Icons.call,
                    size: context.sp(15),
                    color: Colors.white,
                  ),
                  label: contact.phone,
                  color: _kDark,
                  onTap: () => _launchDialer(context, contact.phone),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(8),
            vertical: context.sp(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: context.sp(6)),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
