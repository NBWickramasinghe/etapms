import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final bool rememberMe;
  final bool isPasswordVisible;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.rememberMe = false,
    this.isPasswordVisible = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? rememberMe,
    bool? isPasswordVisible,
    LoginStatus? status,
    String? errorMessage,
  }) =>
      LoginState(
        rememberMe: rememberMe ?? this.rememberMe,
        isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [rememberMe, isPasswordVisible, status, errorMessage];
}
