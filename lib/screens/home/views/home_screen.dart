import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/blocs/cart_bloc/cart_bloc.dart';
import 'package:pizza_app/components/star_rating.dart';
import 'package:pizza_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';
import 'package:pizza_app/screens/home/blocs/search_bloc/search_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';

import 'cart_screen.dart';
import 'details_screen.dart';
import '../../payment/payment_history_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Image.asset('assets/8.png', scale: 14),
            const SizedBox(width: 8),
            const Text(
              'PIZZA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
            ),
          ],
        ),
        actions: [
          // Payment History Icon
          IconButton(
            tooltip: 'Lịch sử thanh toán',
            icon: const Icon(Icons.history, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentHistoryScreen(),
                ),
              );
            },
          ),
          // Search Icon
          IconButton(
            onPressed: () {
              final getPizzaBloc = context.read<GetPizzaBloc>();
              final cartBloc = context.read<CartBloc>();
              final authBloc = context.read<AuthenticationBloc>();
              final state = getPizzaBloc.state;

              if (state is GetPizzaSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => SearchBloc(allPizzas: state.pizzas),
                        ),
                        BlocProvider.value(value: cartBloc),
                        BlocProvider.value(value: authBloc),
                      ],
                      child: const SearchScreen(),
                    ),
                  ),
                );
              }
            },
            icon: const Icon(CupertinoIcons.search),
          ),
          // Cart Icon
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              int itemCount = 0;
              if (cartState is CartLoaded) {
                itemCount = cartState.totalItems;
              }

              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      final cartBloc = context.read<CartBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: cartBloc,
                            child: const CartScreen(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.cart),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Sign Out Icon
          IconButton(
            onPressed: () {
              context.read<SignInBloc>().add(SignOutRequired());
            },
            icon: const Icon(CupertinoIcons.arrow_right_to_line),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GetPizzaBloc, GetPizzaState>(
          builder: (context, state) {
            if (state is GetPizzaSuccess) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 9 / 16,
                ),
                itemCount: state.pizzas.length,
                itemBuilder: (context, int i) {
                  return Material(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        final cartBloc = context.read<CartBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => BlocProvider.value(
                              value: cartBloc,
                              child: DetailsScreen(state.pizzas[i]),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pizza Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.asset(
                              state.pizzas[i].picture,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Card Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Veg/Non-Veg and Spicy Indicators
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: state.pizzas[i].isVeg ? Colors.green : Colors.red,
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              state.pizzas[i].isVeg ? "VEG" : "NON-VEG",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              state.pizzas[i].spicy == 1
                                                  ? "🌶️ BLAND"
                                                  : state.pizzas[i].spicy == 2
                                                      ? "🌶️ BALANCE"
                                                      : "🌶️ SPICY",
                                              style: TextStyle(
                                                color: state.pizzas[i].spicy == 1
                                                    ? Colors.green
                                                    : state.pizzas[i].spicy == 2
                                                        ? Colors.orange
                                                        : Colors.redAccent,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Pizza Name
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      state.pizzas[i].name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Pizza Description
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      state.pizzas[i].description,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Rating Display
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: StreamBuilder<List<Review>>(
                                      stream: RepositoryProvider.of<PizzaRepo>(context)
                                          .getReviewsStreamForPizza(state.pizzas[i].pizzaId),
                                      builder: (context, snapshot) {
                                        final reviews = snapshot.data ?? [];
                                        final averageRating = reviews.isEmpty
                                            ? 0.0
                                            : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                                                (reviews.isEmpty ? 1 : reviews.length);
                                        return Row(
                                          children: [
                                            StarRating(
                                              rating: averageRating,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${reviews.length})',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  // Price and Add to Cart
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "\$${(state.pizzas[i].price - (state.pizzas[i].price * (state.pizzas[i].discount / 100))).toStringAsFixed(1)}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "\$${state.pizzas[i].price.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w700,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            final authState = context.read<AuthenticationBloc>().state;
                                            if (authState.status == AuthenticationStatus.authenticated) {
                                              final userId = authState.user?.userId;
                                              if (userId != null) {
                                                context.read<CartBloc>().add(
                                                      AddToCart(
                                                        pizza: state.pizzas[i],
                                                        quantity: 1,
                                                        userId: userId,
                                                      ),
                                                    );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Added ${state.pizzas[i].name} to cart!'),
                                                    duration: const Duration(seconds: 2),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please log in to add items to cart'),
                                                  duration: Duration(seconds: 2),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            CupertinoIcons.add_circled_solid,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is GetPizzaLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const Center(
                child: Text('An error has occurred...'),
              );
            }
          },
        ),
      ),
    );
  }
}