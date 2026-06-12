import 'package:flutter_bloc/flutter_bloc.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(const ChangePasswordState());

  void toggleCurrentVisibility() =>
      emit(state.copyWith(currentVisible: !state.currentVisible));

  void toggleNewVisibility() =>
      emit(state.copyWith(newVisible: !state.newVisible));

  void toggleConfirmVisibility() =>
      emit(state.copyWith(confirmVisible: !state.confirmVisible));

  void updateNewPassword(String value) {
    emit(state.copyWith(
      newPassword: value,
      strength: _calcStrength(value),
    ));
  }

  PasswordStrength _calcStrength(String pwd) {
    int score = 0;
    if (pwd.length >= 8) score++;
    if (pwd.contains(RegExp(r'[A-Z]'))) score++;
    if (pwd.contains(RegExp(r'[0-9]'))) score++;
    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Future<void> submit(String current, String newPwd, String confirm) async {
    if (current.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      emit(state.copyWith(
        status: ChangePasswordStatus.failure,
        errorMessage: 'All fields are required.',
      ));
      return;
    }
    if (newPwd != confirm) {
      emit(state.copyWith(
        status: ChangePasswordStatus.failure,
        errorMessage: 'New passwords do not match.',
      ));
      return;
    }
    if (_calcStrength(newPwd) == PasswordStrength.weak) {
      emit(state.copyWith(
        status: ChangePasswordStatus.failure,
        errorMessage: 'Password does not meet the requirements.',
      ));
      return;
    }
    emit(state.copyWith(status: ChangePasswordStatus.loading, errorMessage: ''));
    await Future.delayed(const Duration(milliseconds: 800));
    // API integration point — replace delay with real change-password call
    emit(state.copyWith(status: ChangePasswordStatus.success));
  }
}
