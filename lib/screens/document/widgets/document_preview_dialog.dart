import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';
import '../../../core/responsive.dart';
import '../document_screen.dart' show DocumentFileType;

const _kRed = Color(0xFFBF3847);
const _kText = Color(0xFF191C21);

/// Shows a submitted document — an image or PDF, depending on what the
/// employee actually uploaded. The user can pinch-zoom and pan/scroll with
/// their finger directly; no extra buttons needed. Closes via the X icon
/// or by tapping outside.
Future<void> showDocumentPreviewDialog(
  BuildContext context, {
  required String label,
  required DocumentFileType type,
  required String assetPath,
}) {
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
    pageBuilder: (context, _, _) => _DocumentPreviewPage(
      label: label,
      type: type,
      assetPath: assetPath,
    ),
  );
}

class _DocumentPreviewPage extends StatelessWidget {
  final String label;
  final DocumentFileType type;
  final String assetPath;

  const _DocumentPreviewPage({
    required this.label,
    required this.type,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Center(
          child: _DialogContent(
            label: label,
            type: type,
            assetPath: assetPath,
          ),
        ),
      ),
    );
  }
}

class _DialogContent extends StatefulWidget {
  final String label;
  final DocumentFileType type;
  final String assetPath;

  const _DialogContent({
    required this.label,
    required this.type,
    required this.assetPath,
  });

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    if (widget.type == DocumentFileType.pdf) {
      _pdfController = PdfController(
        document: PdfDocument.openAsset(widget.assetPath),
      );
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    // A document viewer needs real room to read/zoom — much larger than a
    // small confirm dialog, while still capped so it never sprawls
    // edge-to-edge or exceeds a short landscape viewport.
    final maxWidth = math.min(520.0, screen.width * 0.94);
    final maxHeight = screen.height * 0.86;

    return ConstrainedBox(
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
            // ── Header: title + close button ────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(16),
                context.sp(12),
                context.sp(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.w700,
                        color: _kText,
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

            // ── Document viewer — pinch-zoom & pan with a finger ─
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(context.sp(14)),
                ),
                child: Container(
                  color: const Color(0xFFF5F0E8),
                  child: _Viewer(
                    type: widget.type,
                    assetPath: widget.assetPath,
                    pdfController: _pdfController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Viewer extends StatelessWidget {
  final DocumentFileType type;
  final String assetPath;
  final PdfController? pdfController;

  const _Viewer({
    required this.type,
    required this.assetPath,
    required this.pdfController,
  });

  @override
  Widget build(BuildContext context) {
    if (type == DocumentFileType.pdf) {
      return PdfView(
        controller: pdfController!,
        scrollDirection: Axis.vertical,
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, _) =>
              const _ViewerError(message: 'Unable to load document'),
        ),
      );
    }

    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      child: Center(
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const _ViewerError(message: 'Unable to load image'),
        ),
      ),
    );
  }
}

class _ViewerError extends StatelessWidget {
  final String message;

  const _ViewerError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.sp(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: context.sp(40), color: _kRed),
            SizedBox(height: context.sp(10)),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: context.sp(12),
                color: _kText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
