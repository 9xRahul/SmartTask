import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC managing authentication lifecycle, session restoration, and user sign-in/out.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitialState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginRequestedEvent>(_onLoginRequested);
    on<AuthRegisterRequestedEvent>(_onRegisterRequested);
    on<AuthLogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Checking session...'));
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AuthenticatedState(user: user));
      } else {
        emit(const UnauthenticatedState());
      }
    } catch (_) {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Signing in...'));
    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticatedState(user: user));
    } on AppException catch (e) {
      emit(AuthFailureState(message: e.message));
    } catch (e) {
      emit(AuthFailureState(message: 'Login failed: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Creating account...'));
    try {
      final user = await registerUseCase(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthenticatedState(user: user));
    } on AppException catch (e) {
      emit(AuthFailureState(message: e.message));
    } catch (e) {
      emit(AuthFailureState(message: 'Registration failed: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Signing out...'));
    try {
      await logoutUseCase();
      emit(const UnauthenticatedState());
    } catch (e) {
      emit(const UnauthenticatedState());
    }
  }
}
