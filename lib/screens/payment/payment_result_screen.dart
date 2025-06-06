import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/payment_bloc/payment_bloc.dart';
import '../../blocs/notification_bloc/notification_bloc.dart';
import '../../components/push_notification_service.dart';
import 'paid_invoice_screen.dart';

class PaymentResultScreen extends StatefulWidget {
  final Map<String, String> queryParameters;

  const PaymentResultScreen({
    super.key,
    required this.queryParameters,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  @override
  void initState() {
    super.initState();
    print('PaymentResultScreen initialized with query parameters: ${widget.queryParameters}');
    // Không gọi context.read ở đây nữa!
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gọi bloc ở đây để tránh lỗi Provider
    context.read<PaymentBloc>().add(
      ValidateVNPayResponse(queryParameters: widget.queryParameters),
    );
  }

  void _navigateToHome() {
    // Chỉ điều hướng về Home, không gọi CartBloc/GetPizzaBloc ở đây nữa!
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: {'refresh_cart': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,      body: BlocListener<PaymentBloc, PaymentState>(        listener: (context, state) {
          if (state is PaymentSuccess) {
            // Don't auto-navigate, let user choose when to go back
            print('Payment successful: ${state.invoice.invoiceId}');
            
            // Hiển thị push notification ngoài app
            PushNotificationService.showPaymentSuccessNotification(
              orderId: state.invoice.invoiceId,
              amount: '\$${state.invoice.totalAmount.toStringAsFixed(2)}',
            );
            
            // Trigger success notification trong app
            context.read<NotificationBloc>().add(
              ShowPaymentSuccessNotification(
                message: 'Payment successful! Order ID: ${state.invoice.invoiceId}',
              ),
            );
          } else if (state is PaymentFailure) {
            // Show error for longer time, then auto-navigate back
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                _navigateToHome();
              }
            });
            
            // Hiển thị push notification thất bại ngoài app
            PushNotificationService.showPaymentFailureNotification(
              error: state.error,
            );
            
            // Trigger failure notification trong app
            context.read<NotificationBloc>().add(
              ShowPaymentFailureNotification(
                message: 'Payment failed: ${state.error}',
              ),
            );
          }
        },
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading || state is PaymentProcessing) {
              return _buildLoadingScreen();
            } else if (state is PaymentSuccess) {
              return _buildSuccessScreen(state);
            } else if (state is PaymentFailure) {
              return _buildFailureScreen(state);
            }
            
            return _buildLoadingScreen();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Processing your payment...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(PaymentSuccess state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Transaction ID: ${state.transactionNo}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your order has been placed successfully!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (state.invoice.invoiceId.isNotEmpty && state.invoice.userId.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaidInvoiceScreen(
                        invoiceId: state.invoice.invoiceId,
                        userId: state.invoice.userId,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Xem chi tiết giao dịch VNPAY'),
            ),
            const SizedBox(height: 40),            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Clear notification before navigating home
                  context.read<NotificationBloc>().add(ClearNotification());
                  await Future.delayed(const Duration(milliseconds: 300));
                  _navigateToHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureScreen(PaymentFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              state.error,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _navigateToHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
