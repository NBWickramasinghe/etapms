import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String employeeId;
  final String password;
  const LoginSubmitted({required this.employeeId, required this.password});
  @override
  List<Object?> get props => [employeeId, password];
}

class LoginRememberMeToggled extends LoginEvent {
  const LoginRememberMeToggled();
}

class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

class LoginReset extends LoginEvent {
  const LoginReset();
}
