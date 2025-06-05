part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentUrlGenerated extends PaymentState {
  final String paymentUrl;
  final String orderId;

  const PaymentUrlGenerated({
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  List<Object> get props => [paymentUrl, orderId];
}

class PaymentProcessing extends PaymentState {
  final String orderId;

  const PaymentProcessing({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class PaymentSuccess extends PaymentState {
  final Invoice invoice;
  final String transactionNo;
  final String bankCode;

  const PaymentSuccess({
    required this.invoice,
    required this.transactionNo,
    required this.bankCode,
  });

  @override
  List<Object> get props => [invoice, transactionNo, bankCode];
}

class PaymentFailure extends PaymentState {
  final String error;
  final String? orderId;
  final String? responseCode;

  const PaymentFailure({
    required this.error,
    this.orderId,
    this.responseCode,
  });

  @override
  List<Object?> get props => [error, orderId, responseCode];
}
