import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finkost/features/authentication/data/repositories/auth_repository.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_event.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      try {
        final user = await authRepository.currentUser;
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUp(
          email: event.email,
          password: event.password,
          name: event.name,
        );
        final user = await authRepository.currentUser;
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signIn(
          email: event.email,
          password: event.password,
        );
        final user = await authRepository.currentUser;
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}