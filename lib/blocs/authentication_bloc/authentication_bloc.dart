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
        add(AuthenticationUserChanged(user));
      },
      onError: (error) {
        // If there's an error in the user stream, try to maintain current state
        // This helps prevent sudden logouts due to network issues
        print('Authentication stream error: $error');
      },
    );

    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != null && event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        // Only emit unauthenticated if we're sure the user is not authenticated
        // This helps prevent temporary logouts during app state changes
        if (state.status != AuthenticationStatus.authenticated) {
          emit(const AuthenticationState.unauthenticated());
        }
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
