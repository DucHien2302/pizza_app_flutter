import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cart_repository/cart_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../blocs/cart_bloc/cart_bloc.dart';
import '../../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../../blocs/payment_bloc/payment_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status == AuthenticationStatus.authenticated) {
      return authState.user!.userId;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,        
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    _showClearCartDialog(context);
                  },                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(        
        builder: (context, state) {
          if (state is CartInitial || state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final userId = _getCurrentUserId(context);
                      if (userId.isNotEmpty) {
                        context.read<CartBloc>().add(LoadCart(userId: userId));
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyCart(context);
            }
            
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _buildCartItem(context, item);
                    },
                  ),
                ),
                _buildBottomSummary(context, state),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.cartShopping,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),          
          Text(
            'Shopping cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add some delicious pizzas to your cart!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Hình ảnh pizza
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.pizza.picture,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            
            // Thông tin pizza
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.pizza.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Giá tiền
                  Row(
                    children: [
                      Text(
                        '\$${(item.pizza.price - (item.pizza.price * (item.pizza.discount / 100))).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (item.pizza.discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.pizza.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Điều khiển số lượng
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [                            IconButton(
                              onPressed: () {
                                if (item.quantity > 1) {
                                  context.read<CartBloc>().add(
                                    UpdateQuantity(
                                      userId: _getCurrentUserId(context),
                                      pizzaId: item.pizza.pizzaId,
                                      quantity: item.quantity - 1,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.remove, size: 18),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),                            
                            IconButton(
                              onPressed: () {
                                context.read<CartBloc>().add(
                                  UpdateQuantity(
                                    userId: _getCurrentUserId(context),
                                    pizzaId: item.pizza.pizzaId,
                                    quantity: item.quantity + 1,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),                      
                      ),
                      const Spacer(),
                      
                      // Delete button
                      IconButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                            RemoveFromCart(
                              userId: _getCurrentUserId(context),
                              pizzaId: item.pizza.pizzaId,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomSummary(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [              Text(
                'Total Items: ${state.totalItems}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Total Price: \$${state.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {        
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(ClearCart(userId: _getCurrentUserId(context)));
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
    void _showCheckoutDialog(BuildContext context) {
    final cartState = context.read<CartBloc>().state;
    if (cartState is! CartLoaded) return;

    final userId = _getCurrentUserId(context);
    if (userId.isEmpty) return;

    // Calculate total amount
    final totalAmount = cartState.items.fold<double>(
      0,
      (sum, item) => sum + (item.pizza.price * item.quantity),
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<PaymentBloc>(),
          child: AlertDialog(
            title: const Text('Checkout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,              
              children: [
                Text(
                  'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'VND Amount: ₫${(totalAmount * 25000).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Payment Method: VNPAY'),
                const SizedBox(height: 20),
                BlocConsumer<PaymentBloc, PaymentState>(                  
                  listener: (context, state) {
                    if (state is PaymentUrlGenerated) {
                      Navigator.of(dialogContext).pop();
                      _launchVNPayUrl(context, state.paymentUrl);
                    } else if (state is PaymentFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment failed: ${state.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is PaymentSuccess) {
                      Navigator.of(dialogContext).pop();
                      _showPaymentSuccessDialog(context);
                    }
                  },
                  builder: (context, state) {
                    if (state is PaymentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),              ElevatedButton(                onPressed: () async {
                  // Test network connection first
                  bool canReachVNPay = await _testVNPayConnection();
                  print('VNPay connectivity test: $canReachVNPay');
                  
                  if (!canReachVNPay) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Network issue: Cannot reach VNPay servers. Please check your internet connection.'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                  
                  // Proceed with payment regardless (URL might still work)
                  context.read<PaymentBloc>().add(
                    CreateVNPayPayment(
                      userId: userId,
                      cartItems: cartState.items,
                      returnUrl: 'pizzaapp://payment_result',
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Pay with VNPAY'),
              ),
            ],
          ),
        );
      },
    );
  }
  // Test network connectivity to VNPay
  Future<bool> _testVNPayConnection() async {
    try {
      final result = await InternetAddress.lookup('sandbox.vnpayment.vn');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('VNPay sandbox is reachable');
        return true;
      }
    } catch (e) {
      print('Cannot reach VNPay sandbox: $e');
    }
    return false;
  }

  Future<void> _launchVNPayUrl(BuildContext context, String url) async {
    try {
      print('Attempting to launch VNPay URL: $url');
      final uri = Uri.parse(url);
      
      // Log URI details
      print('Parsed URI: $uri');
      print('URI scheme: ${uri.scheme}');
      print('URI host: ${uri.host}');
      
      // Check if URL can be launched
      bool canLaunch = await canLaunchUrl(uri);
      print('Can launch URL: $canLaunch');
      
      if (canLaunch) {
        // Try different launch modes
        try {
          // First try with platform default (might open in WebView)
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          print('Successfully launched with platformDefault mode');
        } catch (e1) {
          print('Failed with platformDefault mode: $e1');
          try {
            // Try with external application (opens in browser)
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            print('Successfully launched with externalApplication mode');
          } catch (e2) {
            print('Failed with externalApplication mode: $e2');
            // Last resort: try with inAppWebView
            await launchUrl(
              uri,
              mode: LaunchMode.inAppWebView,
            );
            print('Successfully launched with inAppWebView mode');
          }
        }
      } else {
        throw 'Cannot launch URL: $url';
      }
    } catch (e) {
      print('Error launching VNPAY URL: $e');
      
      // Show detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open payment page: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Copy URL',
            onPressed: () {
              // You could implement clipboard copy here if needed
              print('VNPay URL: $url');
            },
          ),
        ),
      );
    }
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Payment Successful'),
            ],
          ),
          content: const Text(
            'Your payment has been processed successfully! Your order is being prepared.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navigate back to home or orders screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
