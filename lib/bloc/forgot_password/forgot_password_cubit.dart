import 'package:flutter_bloc/flutter_bloc.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(const ForgotPasswordState());

  Future<void> submit(String employeeId) async {
    if (employeeId.trim().isEmpty) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: 'Please enter your Worker / Employee ID.',
      ));
      return;
    }
    emit(state.copyWith(
      status: ForgotPasswordStatus.loading,
      errorMessage: '',
    ));
    await Future.delayed(const Duration(milliseconds: 800));
    // API integration point — replace with the real password-reset request
    emit(state.copyWith(status: ForgotPasswordStatus.success));
  }
}
