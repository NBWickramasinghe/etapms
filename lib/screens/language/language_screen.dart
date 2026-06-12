import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/locale/locale_cubit.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';

const _kDark  = Color(0xFF242F31);
const _kGreen = Color(0xFF354E48);
const _kText  = Color(0xFF191C21);
const _kBg    = Color(0xFFF5F0E8);

// Language direction is handled automatically by Flutter via
// GlobalWidgetsLocalizations.delegate — no extra plugin needed.
// All 6 current languages are LTR. Adding an RTL locale (e.g. 'ar')
// to the ARB files and supportedLocales is all that's needed later.
const _languages = [
  _LangOption(code: 'en', nativeName: 'English',  englishName: 'English'),
  _LangOption(code: 'ar', nativeName: 'العربية',  englishName: 'Arabic'),
  _LangOption(code: 'si', nativeName: 'සිංහල',   englishName: 'Sinhala'),
  _LangOption(code: 'hi', nativeName: 'हिन्दी',   englishName: 'Hindi'),
  _LangOption(code: 'zh', nativeName: '中文',      englishName: 'Chinese'),
  _LangOption(code: 'ru', nativeName: 'Русский',   englishName: 'Russian'),
  _LangOption(code: 'th', nativeName: 'ไทย',      englishName: 'Thai'),
];

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(16),
                vertical: context.sp(14),
              ),
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
                    l.language,
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

            // ── Subtitle ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sp(20), 0, context.sp(20), context.sp(12)),
              child: Text(
                l.selectPreferredLanguage,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(12),
                  color: _kText.withValues(alpha: 0.45),
                  letterSpacing: 0,
                ),
              ),
            ),

            // ── Language list ─────────────────────────────────────
            Expanded(
              child: BlocBuilder<LocaleCubit, Locale>(
                builder: (context, current) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                    itemCount: _languages.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: context.sp(10)),
                    itemBuilder: (context, i) {
                      final lang = _languages[i];
                      final selected =
                          current.languageCode == lang.code;
                      return _LangTile(
                        lang: lang,
                        isSelected: selected,
                        onTap: () {
                          context
                              .read<LocaleCubit>()
                              .setLocale(Locale(lang.code));
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: context.sp(16)),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final _LangOption lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangTile({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(16),
          vertical: context.sp(14),
        ),
        decoration: BoxDecoration(
          color: isSelected ? _kGreen : Colors.white,
          border: Border.all(
            color: isSelected
                ? _kGreen
                : _kGreen.withValues(alpha: 0.30),
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            // Language indicator strip
            Container(
              width: context.sp(3),
              height: context.sp(36),
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.5)
                  : _kGreen.withValues(alpha: 0.25),
            ),
            SizedBox(width: context.sp(14)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Native script name
                  Text(
                    lang.nativeName,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _kText,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: context.sp(2)),
                  // English label
                  Text(
                    lang.englishName,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.70)
                          : _kText.withValues(alpha: 0.45),
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark for selected
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                width: context.sp(26),
                height: context.sp(26),
                color: Colors.white.withValues(alpha: 0.20),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: context.sp(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String nativeName;
  final String englishName;

  const _LangOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });
}
