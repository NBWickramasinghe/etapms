import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/document_preview_dialog.dart';

const _kDark = Color(0xFF242F31);
const _kGreen = Color(0xFF354E48);
const _kText = Color(0xFF191C21);
const _kBg = Color(0xFFF5F0E8);

enum DocumentFileType { image, pdf }

class _DocumentItem {
  final String Function(AppLocalizations l) label;
  final IconData icon;
  final DocumentFileType type;
  final String assetPath;

  const _DocumentItem({
    required this.label,
    required this.icon,
    required this.type,
    required this.assetPath,
  });
}

const _kDocumentsDir = 'assets/Documents';

// Dummy submitted documents — API integration point — replace with the
// employee's real uploaded documents fetched from the backend. For the
// demo these are the actual files bundled under assets/Documents/.
const _dummyDocuments = <_DocumentItem>[
  _DocumentItem(
    label: _passportLabel,
    icon: Icons.badge,
    type: DocumentFileType.image,
    assetPath: '$_kDocumentsDir/passport.jpeg',
  ),
  _DocumentItem(
    label: _visaLabel,
    icon: Icons.flight_takeoff,
    type: DocumentFileType.pdf,
    assetPath: '$_kDocumentsDir/Visa_2026.pdf',
  ),
  _DocumentItem(
    label: _insuranceLabel,
    icon: Icons.health_and_safety,
    type: DocumentFileType.image,
    assetPath: '$_kDocumentsDir/medical.jpeg',
  ),
  _DocumentItem(
    label: _safetyCertificateLabel,
    icon: Icons.verified_user,
    type: DocumentFileType.image,
    assetPath: '$_kDocumentsDir/safety_Certificate.jpeg',
  ),
  _DocumentItem(
    label: _reEntryLabel,
    icon: Icons.assignment_return,
    type: DocumentFileType.pdf,
    assetPath: '$_kDocumentsDir/reentry.pdf',
  ),
  _DocumentItem(
    label: _flightTicketsLabel,
    icon: Icons.airplane_ticket,
    type: DocumentFileType.pdf,
    assetPath: '$_kDocumentsDir/Flight_Ticket.pdf',
  ),
  _DocumentItem(
    label: _agreementLabel,
    icon: Icons.description,
    type: DocumentFileType.pdf,
    assetPath: '$_kDocumentsDir/AIA_Roshal_Working_Agreement.pdf',
  ),
];

String _passportLabel(AppLocalizations l) => l.passport;
String _visaLabel(AppLocalizations l) => l.visa;
String _insuranceLabel(AppLocalizations l) => l.medicalInsurance;
String _safetyCertificateLabel(AppLocalizations l) => l.safetyCertificate;
String _reEntryLabel(AppLocalizations l) => l.reEntryDocument;
String _flightTicketsLabel(AppLocalizations l) => l.flightTickets;
String _agreementLabel(AppLocalizations l) => l.workAgreement;

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

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
                l.document,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(22),
                  fontWeight: FontWeight.w700,
                  color: _kText,
                  letterSpacing: 0,
                ),
              ),
            ),

            SizedBox(height: context.sp(12)),

            // ── Document list ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final doc in _dummyDocuments) ...[
                      _DocumentRow(item: doc),
                      SizedBox(height: context.sp(12)),
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

class _DocumentRow extends StatelessWidget {
  final _DocumentItem item;

  const _DocumentRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = item.label(l);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showDocumentPreviewDialog(
        context,
        label: label,
        type: item.type,
        assetPath: item.assetPath,
      ),
      child: Container(
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
            Icon(item.icon, size: context.sp(19), color: _kDark),
            SizedBox(width: context.sp(14)),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w500,
                  color: _kText,
                  letterSpacing: 0,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: context.sp(20),
              color: _kDark.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
