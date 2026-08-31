import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/refresh_session_use_case.dart';
import '../../domain/usecases/register_use_case.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}

final class RegisterSubmitted extends AuthEvent {
  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;
}

final class RefreshRequested extends AuthEvent {
  const RefreshRequested();
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final AuthSession session;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated([this.failure]);

  final Failure? failure;
}

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._login, this._register, this._refresh, this._logout)
    : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<RefreshRequested>(_onRefresh);
    on<LogoutRequested>(_onLogout);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final RefreshSessionUseCase _refresh;
  final LogoutUseCase _logout;

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _login(email: event.email, password: event.password);
    _emitResult(result, emit);
  }

  Future<void> _onRegister(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _register(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    _emitResult(result, emit);
  }

  Future<void> _onRefresh(
    RefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _refresh();
    _emitResult(result, emit);
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }

  void _emitResult(
    ({AuthSession? session, Failure? failure}) result,
    Emitter<AuthState> emit,
  ) {
    final session = result.session;
    if (session != null) {
      emit(AuthAuthenticated(session));
    } else {
      emit(AuthUnauthenticated(result.failure));
    }
  }
}
