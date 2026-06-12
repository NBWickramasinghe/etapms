import 'package:equatable/equatable.dart';

enum ChangePasswordStatus { initial, loading, success, failure }

enum PasswordStrength { weak, medium, strong }

class ChangePasswordState extends Equatable {
  final bool currentVisible;
  final bool newVisible;
  final bool confirmVisible;
  final ChangePasswordStatus status;
  final String errorMessage;
  final PasswordStrength strength;
  final String newPassword;

  const ChangePasswordState({
    this.currentVisible = false,
    this.newVisible = false,
    this.confirmVisible = false,
    this.status = ChangePasswordStatus.initial,
    this.errorMessage = '',
    this.strength = PasswordStrength.weak,
    this.newPassword = '',
  });

  ChangePasswordState copyWith({
    bool? currentVisible,
    bool? newVisible,
    bool? confirmVisible,
    ChangePasswordStatus? status,
    String? errorMessage,
    PasswordStrength? strength,
    String? newPassword,
  }) =>
      ChangePasswordState(
        currentVisible: currentVisible ?? this.currentVisible,
        newVisible: newVisible ?? this.newVisible,
        confirmVisible: confirmVisible ?? this.confirmVisible,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        strength: strength ?? this.strength,
        newPassword: newPassword ?? this.newPassword,
      );

  @override
  List<Object?> get props => [
        currentVisible,
        newVisible,
        confirmVisible,
        status,
        errorMessage,
        strength,
        newPassword,
      ];
}
