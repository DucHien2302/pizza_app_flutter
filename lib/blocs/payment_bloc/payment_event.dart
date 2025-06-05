part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create VNPAY payment URL
class CreateVNPayPayment extends PaymentEvent {
  final String userId;
  final List<CartItem> cartItems;
  final String returnUrl;

  const CreateVNPayPayment({
    required this.userId,
    required this.cartItems,
    required this.returnUrl,
  });

  @override
  List<Object?> get props => [userId, cartItems, returnUrl];
}

/// Event to validate VNPAY response
class ValidateVNPayResponse extends PaymentEvent {
  final Map<String, String> queryParameters;

  const ValidateVNPayResponse({required this.queryParameters});

  @override
  List<Object?> get props => [queryParameters];
}
