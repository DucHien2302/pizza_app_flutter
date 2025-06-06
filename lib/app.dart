import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:cart_repository/cart_repository.dart';
import 'package:payment_repository/payment_repository.dart';
import 'app_view.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'blocs/payment_bloc/payment_bloc.dart';
import 'blocs/notification_bloc/notification_bloc.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => userRepository,
        ),
        RepositoryProvider<CartRepository>(
          create: (context) => FirebaseCartRepository(),
        ),
        RepositoryProvider<PaymentRepository>(
          create: (context) => FirebasePaymentRepository(
            cartRepository: context.read<CartRepository>(),
          ),
        ),
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(userRepository: userRepository),
        ),        BlocProvider<PaymentBloc>(
          create: (context) => PaymentBloc(
            paymentRepository: context.read<PaymentRepository>(),
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(),
        ),
      ],
      child: const MyAppView(),
    );
  }
}
