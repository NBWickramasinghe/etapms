import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../../core/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../models/profile_model.dart';

const _kDark   = Color(0xFF242F31);
const _kText   = Color(0xFF191C21);
const _kGreen  = Color(0xFF354E48);
const _kBg     = Color(0xFFF5F0E8);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────
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
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            width: context.sp(40),
                            height: context.sp(40),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back,
                                color: _kText,
                                size: context.sp(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        l.myProfile,
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

                // ── Avatar ─────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: context.sp(3)),
                  ),
                  child: CircleAvatar(
                    radius: context.sp(48),
                    backgroundColor: _kGreen,
                    child: Icon(Icons.person, size: context.sp(56), color: Colors.white),
                  ),
                ),

                SizedBox(height: context.sp(20)),

                // ── Scrollable fields ───────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                    child: _ProfileFields(profile: state.profile, l: l),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileFields extends StatelessWidget {
  final ProfileModel profile;
  final AppLocalizations l;

  const _ProfileFields({required this.profile, required this.l});

  @override
  Widget build(BuildContext context) {
    final fields = [
      _FieldData(l.employeeNo,     Icons.badge,            profile.employeeNo),
      _FieldData(l.joinedDate,     Icons.calendar_today,   profile.joinedDate),
      _FieldData(l.country,        Icons.public,           profile.country),
      _FieldData(l.position,       Icons.work,             profile.position),
      _FieldData(l.surname,        Icons.person,           profile.surname),
      _FieldData(l.otherName,      Icons.person,           profile.otherName),
      _FieldData(l.birthday,       Icons.cake,             profile.birthday),
      _FieldData(l.passportNo,     Icons.travel_explore,   profile.passportNo),
      _FieldData(l.email,          Icons.mail,             profile.email),
      _FieldData(l.gender,         Icons.wc,               profile.gender),
      _FieldData(l.mobileNumber,   Icons.phone,            profile.mobileNumber),
      _FieldData(l.whatsAppNumber, Icons.chat,             profile.whatsAppNumber),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...fields.map((f) => Padding(
              padding: EdgeInsets.only(bottom: context.sp(12)),
              child: _ProfileField(data: f),
            )),
        SizedBox(height: context.sp(16)),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final _FieldData data;

  const _ProfileField({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.label,
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
              Icon(data.icon, size: context.sp(19), color: _kDark),
              SizedBox(width: context.sp(14)),
              Expanded(
                child: Text(
                  data.value,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w400,
                    color: _kText,
                    letterSpacing: 0,
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

class _FieldData {
  final String label;
  final IconData icon;
  final String value;

  const _FieldData(this.label, this.icon, this.value);
}
