import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/blocs/cart_bloc/cart_bloc.dart';
import 'package:pizza_app/blocs/payment_bloc/payment_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:cart_repository/cart_repository.dart';

import 'screens/auth/views/welcome_screen.dart';
import 'screens/home/views/home_screen.dart';
import 'screens/payment/payment_result_screen.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  final _appLinks = AppLinks();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Listen for incoming links
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleIncomingLink(uri);
    });
  }

  void _handleIncomingLink(Uri uri) {
    if (uri.path == '/payment_result') {
      // Navigate to payment result screen with query parameters
      _navigatorKey.currentState?.pushNamed(
        '/payment_result',
        arguments: uri.queryParameters,
      );
    }
  }  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Pizza Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: Colors.blue,
          onPrimary: Colors.white,
        ),
      ),
      routes: {
        '/payment_result': (context) {
          // Extract query parameters from route settings
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: context.read<PaymentBloc>(),
              ),
            ],
            child: PaymentResultScreen(
              queryParameters: args ?? {},
            ),
          );
        },
      },
      onGenerateRoute: (settings) {
        // Handle deep links with query parameters
        if (settings.name?.startsWith('/payment_result') == true) {
          final uri = Uri.parse(settings.name!);
          final queryParameters = uri.queryParameters;
          
          return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: context.read<PaymentBloc>(),
                ),
              ],
              child: PaymentResultScreen(
                queryParameters: queryParameters,
              ),
            ),
          );
        }
        return null;
      },
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => SignInBloc(
                    context.read<UserRepository>(),
                  ),
                ),
                BlocProvider(create: (context) => GetPizzaBloc(
                  FirebasePizzaRepo()
                )..add(GetPizza())
              ),
                BlocProvider(create: (context) => CartBloc(
                  cartRepository: context.read<CartRepository>(),
                )..add(LoadCart(userId: state.user!.userId))),
              ],
              child: const HomeScreen(),
            );
          } else {
            return WelcomeScreen();
          }
        },
      ),
    );
  }
}
