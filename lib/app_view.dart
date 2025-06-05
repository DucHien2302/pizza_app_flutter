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
import 'package:payment_repository/payment_repository.dart';

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
    print('Incoming deep link: $uri');
    print('URI path: ${uri.path}');
    print('URI host: ${uri.host}');
    print('URI query parameters: ${uri.queryParameters}');
    
    // Handle both path-based and host-based deep links
    // pizza://payment_result -> host = 'payment_result', path = ''
    // pizza:///payment_result -> host = '', path = '/payment_result'
    if (uri.path == '/payment_result' || uri.path == 'payment_result' || uri.host == 'payment_result') {
      // Wait a bit for authentication state to stabilize
      // This helps ensure the user is properly authenticated when returning from payment
      Future.delayed(const Duration(milliseconds: 500), () {
        // Check if we have a current context and the navigator is ready
        if (_navigatorKey.currentState != null) {
          _navigatorKey.currentState?.pushNamed(
            '/payment_result',
            arguments: uri.queryParameters,
          );
        }
      });
    }
  }

  @override
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
      initialRoute: '/',      onGenerateRoute: (settings) {
        // Handle named routes
        switch (settings.name) {
          case '/':
            // Home route - return to the appropriate screen based on auth status
            final args = settings.arguments as Map<String, dynamic>?;
            final shouldRefreshCart = args?['refresh_cart'] == true;
            
            return MaterialPageRoute(
              builder: (context) => BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) {
                  if (state.status == AuthenticationStatus.authenticated) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => SignInBloc(
                            context.read<UserRepository>(),
                          ),
                        ),
                        BlocProvider(
                          create: (context) => GetPizzaBloc(
                            FirebasePizzaRepo()
                          )..add(GetPizza())
                        ),
                        BlocProvider(
                          create: (context) {
                            final cartBloc = CartBloc(
                              cartRepository: context.read<CartRepository>(),
                            );
                            
                            if (shouldRefreshCart && state.user != null) {
                              // Refresh cart after payment
                              cartBloc.add(RefreshCart(userId: state.user!.userId));
                            } else if (state.user != null) {
                              // Normal load cart
                              cartBloc.add(LoadCart(userId: state.user!.userId));
                            }
                            
                            return cartBloc;
                          },
                        ),
                      ],
                      child: const HomeScreen(),
                    );
                  } else {
                    return WelcomeScreen();
                  }
                },
              ),
            );
            
          case '/payment_result':
            // Extract query parameters from route settings
            final args = settings.arguments as Map<String, String>?;
            return MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => PaymentBloc(
                      paymentRepository: context.read<PaymentRepository>(),
                    ),
                  ),
                ],
                child: PaymentResultScreen(
                  queryParameters: args ?? {},
                ),
              ),
            );
            
          default:
            // Return null for unknown routes - this will show a 404 page
            return null;
        }
      },
    );
  }
}