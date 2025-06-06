import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/blocs/cart_bloc/cart_bloc.dart';
import 'package:pizza_app/blocs/review_bloc/review_bloc.dart';
import 'package:pizza_app/components/micro.dart';
import 'package:pizza_app/components/star_rating.dart';
import 'package:pizza_app/screens/reviews/reviews_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';

class DetailsScreen extends StatefulWidget {
  final Pizza pizza;
  const DetailsScreen(this.pizza, {super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1;
  String? _getCurrentUserId() {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status == AuthenticationStatus.authenticated) {
      return authState.user?.userId;
    }
    return null;
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width - (40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5
                  )
                ],
                image: DecorationImage(
                  image: AssetImage(
                    widget.pizza.picture
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.pizza.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${widget.pizza.price - (widget.pizza.price * (widget.pizza.discount / 100))}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                ),
                                Text(
                                  '\$${widget.pizza.price}.00',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),                    Row(
                      children: [
                        MyMicroWidget(
                          title: 'Calories',
                          value: widget.pizza.macros.calories,
                          icon: FontAwesomeIcons.fire,
                        ),
                        SizedBox(width: 10,),
                        MyMicroWidget(
                          title: 'Protein',
                          value: widget.pizza.macros.proteins,
                          icon: FontAwesomeIcons.dumbbell,
                        ),
                        SizedBox(width: 10),
                        MyMicroWidget(
                          title: 'Fat',
                          value: widget.pizza.macros.fat,
                          icon: FontAwesomeIcons.oilWell,
                        ),
                        SizedBox(width: 10),
                        MyMicroWidget(
                          title: 'Carbs',
                          value: widget.pizza.macros.carbs,
                          icon: FontAwesomeIcons.breadSlice,
                        ),
                      ],
                    ),                    SizedBox(height: 12),
                    // Rating and Reviews section
                    BlocProvider(
                      create: (context) => ReviewBloc(
                        RepositoryProvider.of<PizzaRepo>(context),
                      )..add(GetReviewsEvent(widget.pizza.pizzaId)),
                      child: BlocBuilder<ReviewBloc, ReviewState>(
                        builder: (context, reviewState) {
                          if (reviewState is ReviewLoaded) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewsScreen(pizza: widget.pizza),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    StarRating(
                                      rating: reviewState.averageRating,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${reviewState.averageRating.toStringAsFixed(1)} (${reviewState.reviewCount} đánh giá)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (reviewState is ReviewError) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Text(
                                'Chưa có đánh giá - Nhấn để thêm đánh giá đầu tiên',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    SizedBox(height: 40),
                    // Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Số lượng: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove),
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                icon: const Icon(Icons.add),
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: TextButton(                        onPressed: () {
                          final userId = _getCurrentUserId();
                          if (userId != null) {
                            context.read<CartBloc>().add(
                              AddToCart(
                                pizza: widget.pizza, 
                                quantity: quantity, 
                                userId: userId
                              ),
                            );
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${widget.pizza.name} to cart!'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            // Show error message if user is not authenticated
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please log in to add items to cart'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          elevation: 3.0,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),                        ), 
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}