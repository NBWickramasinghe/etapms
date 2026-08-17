import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import '../../bloc/payslip/payslip_cubit.dart';
import '../../bloc/payslip/payslip_state.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/payslip_pdf_full_view.dart';

const _kDark = Color(0xFF242F31);
const _kGreen = Color(0xFF354E48);
const _kText = Color(0xFF191C21);
const _kBg = Color(0xFFF5F0E8);

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PayslipCubit(),
      child: const _PayslipView(),
    );
  }
}

class _PayslipView extends StatelessWidget {
  const _PayslipView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocBuilder<PayslipCubit, PayslipState>(
      builder: (context, state) {
        final cubit = context.read<PayslipCubit>();
        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.sp(20),
                    context.sp(20),
                    context.sp(20),
                    context.sp(4),
                  ),
                  child: Text(
                    l.payslip,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(22),
                      fontWeight: FontWeight.w700,
                      color: _kText,
                      letterSpacing: 0,
                    ),
                  ),
                ),

                // ── Filter row: Year | Month | View ─────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(20),
                    vertical: context.sp(12),
                  ),
                  child: Row(
                    children: [
                      // Year
                      Expanded(
                        child: _DropdownField(
                          label: l.year,
                          value: state.selectedYear?.toString(),
                          onTap: () => _pickYear(context, cubit),
                        ),
                      ),
                      SizedBox(width: context.sp(8)),
                      // Month
                      Expanded(
                        child: _DropdownField(
                          label: l.month,
                          value: state.selectedMonth != null
                              ? _monthName(context, state.selectedMonth!)
                              : null,
                          onTap: () => _pickMonth(context, cubit),
                        ),
                      ),
                      SizedBox(width: context.sp(8)),
                      // View button
                      _ViewButton(
                        label: l.view,
                        enabled: state.canView,
                        isLoading: state.isLoading,
                        onTap: cubit.viewPayslip,
                      ),
                    ],
                  ),
                ),

                // ── Content ──────────────────────────────────────
                Expanded(
                  child: state.isViewing && state.data != null
                      ? _PayslipCard(data: state.data!)
                      : _EmptyState(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Year bottom-sheet ─────────────────────────────────────────
  void _pickYear(BuildContext context, PayslipCubit cubit) {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 2019, (i) => currentYear - i);
    _showPickerSheet(
      context: context,
      items: years.map((y) => y.toString()).toList(),
      onSelected: (i) => cubit.selectYear(years[i]),
    );
  }

  // ── Month bottom-sheet ────────────────────────────────────────
  void _pickMonth(BuildContext context, PayslipCubit cubit) {
    final locale = Localizations.localeOf(context).languageCode;
    final months = List.generate(
      12,
      (i) => DateFormat('MMMM', locale).format(DateTime(2000, i + 1)),
    );
    _showPickerSheet(
      context: context,
      items: months,
      onSelected: (i) => cubit.selectMonth(i + 1),
    );
  }

  // ── Shared bottom-sheet picker ────────────────────────────────
  void _showPickerSheet({
    required BuildContext context,
    required List<String> items,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (_, i) => InkWell(
          onTap: () {
            Navigator.pop(context);
            onSelected(i);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.sp(24),
              vertical: context.sp(14),
            ),
            child: Text(
              items[i],
              style: GoogleFonts.poppins(
                fontSize: context.sp(15),
                fontWeight: FontWeight.w500,
                color: _kText,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(BuildContext context, int month) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('MMMM', locale).format(DateTime(2000, month));
  }
}

// ── Dropdown field ────────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: context.sp(48),
        padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
        color: _kDark,
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : label,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(13),
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withValues(alpha: 0.7),
              size: context.sp(18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── View button ───────────────────────────────────────────────────────────────

class _ViewButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _ViewButton({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: context.sp(48),
        padding: EdgeInsets.symmetric(horizontal: context.sp(14)),
        color: enabled ? _kGreen : _kGreen.withValues(alpha: 0.4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: context.sp(16),
                height: context.sp(16),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                Icons.receipt_long_outlined,
                color: Colors.white,
                size: context.sp(17),
              ),
            SizedBox(width: context.sp(6)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: context.sp(56),
            color: _kText.withValues(alpha: 0.25),
          ),
          SizedBox(height: context.sp(24)),
          Text(
            'Select year and month\nto view your payslip',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w500,
              color: _kText.withValues(alpha: 0.45),
              letterSpacing: 0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payslip card ──────────────────────────────────────────────────────────────

class _PayslipCard extends StatelessWidget {
  final PayslipData data;

  const _PayslipCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final monthName = DateFormat(
      'MMMM',
      locale,
    ).format(DateTime(data.year, data.month));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.sp(20),
        context.sp(4),
        context.sp(20),
        context.sp(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Payslip document — tap to view large, scroll & zoom ─
          Text(
            'Payslip Document',
            style: GoogleFonts.poppins(
              fontSize: context.sp(15),
              fontWeight: FontWeight.w700,
              color: _kText,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: context.sp(12)),
          _PayslipPdfPreview(
            key: ValueKey(data.pdfAssetPath),
            assetPath: data.pdfAssetPath,
            title: '$monthName ${data.year}',
          ),

          SizedBox(height: context.sp(16)),

          // ── Action buttons ─────────────────────────────────
          Row(
            children: [
              // Share
              Expanded(
                child: _ActionBtn(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: _kDark,
                  onTap: () {}, // TODO: wire share API
                ),
              ),
              SizedBox(width: context.sp(10)),
              // View PDF
              Expanded(
                child: _ActionBtn(
                  icon: Icons.remove_red_eye_outlined,
                  label: 'View PDF',
                  color: _kGreen,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PayslipPdfFullView(
                        assetPath: data.pdfAssetPath,
                        title: '$monthName ${data.year}',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.sp(10)),

          // Download — full width
          _ActionBtn(
            icon: Icons.download_outlined,
            label: 'Download',
            color: _kGreen,
            fullWidth: true,
            onTap: () {}, // TODO: wire download API
          ),
        ],
      ),
    );
  }
}

// ── Payslip PDF preview ─────────────────────────────────────────────────────────

class _PayslipPdfPreview extends StatefulWidget {
  final String assetPath;
  final String title;

  const _PayslipPdfPreview({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  State<_PayslipPdfPreview> createState() => _PayslipPdfPreviewState();
}

class _PayslipPdfPreviewState extends State<_PayslipPdfPreview> {
  late final PdfController _controller = PdfController(
    document: PdfDocument.openAsset(widget.assetPath),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PayslipPdfFullView(
            assetPath: widget.assetPath,
            title: widget.title,
          ),
        ),
      ),
      child: Container(
        height: context.hp(36),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sp(8)),
          border: Border.all(
            color: _kGreen.withValues(alpha: 0.18),
            width: 1.2,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview only — tapping opens the scrollable, zoomable view.
            AbsorbPointer(
              child: PdfView(
                controller: _controller,
                scrollDirection: Axis.vertical,
                builders: PdfViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  pageLoaderBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, _) => Center(
                    child: Icon(
                      Icons.error_outline,
                      color: const Color(0xFFBF3847),
                      size: context.sp(32),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: context.sp(10),
              bottom: context.sp(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sp(10),
                  vertical: context.sp(6),
                ),
                decoration: BoxDecoration(
                  color: _kDark.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(context.sp(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: context.sp(14),
                    ),
                    SizedBox(width: context.sp(4)),
                    Text(
                      'Tap to enlarge',
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                    ),
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

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool fullWidth;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: context.sp(48),
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: context.sp(17)),
            SizedBox(width: context.sp(8)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
    return child;
  }
}
