import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginReset>(_onReset);
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    if (event.employeeId.trim().isEmpty || event.password.trim().isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Please enter Employee ID and Password.',
      ));
      return;
    }
    emit(state.copyWith(status: LoginStatus.loading));
    // Backend integration point — simulate short delay for now
    await Future.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(status: LoginStatus.success));
  }

  void _onRememberMeToggled(
      LoginRememberMeToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  void _onPasswordVisibilityToggled(
      LoginPasswordVisibilityToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onReset(LoginReset event, Emitter<LoginState> emit) {
    emit(const LoginState());
  }
}
