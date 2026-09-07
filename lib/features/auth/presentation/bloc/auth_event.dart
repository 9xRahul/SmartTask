import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on app launch to check if user has an existing authenticated session
class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

/// Dispatched when submitting login credentials
class AuthLoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequestedEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when submitting new user registration
class AuthRegisterRequestedEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterRequestedEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Dispatched when user triggers logout
class AuthLogoutRequestedEvent extends AuthEvent {
  const AuthLogoutRequestedEvent();
}
