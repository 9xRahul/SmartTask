import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to session check
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// State emitted while authenticating or checking session
class AuthLoadingState extends AuthState {
  final String? message;

  const AuthLoadingState({this.message});

  @override
  List<Object?> get props => [message];
}

/// State emitted when user is successfully authenticated
class AuthenticatedState extends AuthState {
  final UserProfileEntity user;

  const AuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State emitted when user is unauthenticated (logged out or no active session)
class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

/// State emitted when an authentication operation fails
class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
