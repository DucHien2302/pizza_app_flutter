import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubscription;
  AuthenticationBloc({required this.userRepository})
    : super(const AuthenticationState.unknown()) {
    _userSubscription = userRepository.user.listen(
      (user) {
        print('AuthenticationBloc: User changed - ${user?.email ?? 'null'}');
        add(AuthenticationUserChanged(user));
      },
      onError: (error) {
        // If there's an error in the user stream, try to maintain current state
        // This helps prevent sudden logouts due to network issues
        print('Authentication stream error: $error');
      },
    );    on<AuthenticationUserChanged>((event, emit) {
      print('AuthenticationBloc: Processing user change - ${event.user?.email ?? 'null'}');
      if (event.user != null && event.user != MyUser.empty) {
        print('AuthenticationBloc: Emitting authenticated state');
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        // Always emit unauthenticated when user is null or empty
        // This ensures logout works properly
        print('AuthenticationBloc: Emitting unauthenticated state');
        emit(const AuthenticationState.unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
