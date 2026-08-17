import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/responsive.dart';

const _kDark = Color(0xFF242F31);
const _kViewerBg = Color(0xFF11151A);
const _kRed = Color(0xFFBF3847);

/// Full-screen payslip document — scroll through pages and pinch to zoom.
/// Opened by tapping the payslip preview or the "View PDF" action.
class PayslipPdfFullView extends StatefulWidget {
  final String assetPath;
  final String title;

  const PayslipPdfFullView({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  State<PayslipPdfFullView> createState() => _PayslipPdfFullViewState();
}

class _PayslipPdfFullViewState extends State<PayslipPdfFullView> {
  // pdfx's pinch-to-zoom viewer isn't implemented on Windows desktop —
  // fall back to the plain paged viewer wrapped in InteractiveViewer there
  // so scroll + zoom (via trackpad/mouse-wheel) still work.
  late final bool _pinchZoomSupported = !kIsWeb && !Platform.isWindows;

  PdfControllerPinch? _pinchController;
  PdfController? _pagedController;

  @override
  void initState() {
    super.initState();
    if (_pinchZoomSupported) {
      _pinchController = PdfControllerPinch(
        document: PdfDocument.openAsset(widget.assetPath),
      );
    } else {
      _pagedController = PdfController(
        document: PdfDocument.openAsset(widget.assetPath),
      );
    }
  }

  @override
  void dispose() {
    _pinchController?.dispose();
    _pagedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kViewerBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: _pinchZoomSupported
            ? PdfViewPinch(
                controller: _pinchController!,
                scrollDirection: Axis.vertical,
                builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) => const _ViewerLoader(),
                  pageLoaderBuilder: (_) => const _ViewerLoader(),
                  errorBuilder: (_, _) => const _ViewerError(),
                ),
              )
            // PdfViewPinch has no Windows support, and nesting PdfView inside
            // InteractiveViewer breaks its own page-scrolling (the viewer
            // swallows the drag gesture), so Windows gets scroll without
            // pinch-zoom here — the same plain PdfView already used for
            // document previews elsewhere in the app.
            : PdfView(
                controller: _pagedController!,
                scrollDirection: Axis.vertical,
                builders: PdfViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) => const _ViewerLoader(),
                  pageLoaderBuilder: (_) => const _ViewerLoader(),
                  errorBuilder: (_, _) => const _ViewerError(),
                ),
              ),
      ),
    );
  }
}

class _ViewerLoader extends StatelessWidget {
  const _ViewerLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
}

class _ViewerError extends StatelessWidget {
  const _ViewerError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: _kRed, size: context.sp(40)),
          SizedBox(height: context.sp(10)),
          Text(
            'Unable to load payslip',
            style: GoogleFonts.poppins(
              fontSize: context.sp(13),
              color: Colors.white70,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
