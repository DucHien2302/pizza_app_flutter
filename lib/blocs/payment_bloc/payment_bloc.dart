import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:payment_repository/payment_repository.dart';
import 'package:cart_repository/cart_repository.dart';
part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;
  PaymentBloc({
    required PaymentRepository paymentRepository,
  })  : _paymentRepository = paymentRepository,
        super(const PaymentInitial()) {
    on<CreateVNPayPayment>(_onCreateVNPayPayment);
    on<ValidateVNPayResponse>(_onValidateVNPayResponse);
  }
  Future<void> _onCreateVNPayPayment(
    CreateVNPayPayment event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentLoading());

      // Create invoice with cart items
      final invoice = await _paymentRepository.createInvoice(
        userId: event.userId,
        cartItems: event.cartItems,
        paymentMethod: 'VNPAY',
      );

      // Calculate total amount from cart items
      final totalAmount = event.cartItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

      // Generate VNPAY payment URL
      final paymentUrl = await _paymentRepository.createVNPayPaymentUrl(
        orderId: invoice.invoiceId,
        amount: totalAmount, // Amount in USD, will be converted to VND in VNPay service
        orderInfo: 'Payment for Invoice ${invoice.invoiceId} with \$${invoice.totalAmount}',
        returnUrl: event.returnUrl,
      );

      emit(PaymentUrlGenerated(
        paymentUrl: paymentUrl,
        orderId: invoice.invoiceId,
      ));
    } catch (error) {
      emit(PaymentFailure(error: error.toString()));
    }
  }

  Future<void> _onValidateVNPayResponse(
    ValidateVNPayResponse event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final orderId = event.queryParameters['vnp_TxnRef'] ?? '';
      print('Validating VNPay response for order: $orderId');
      print('Query parameters: ${event.queryParameters}');
      
      emit(PaymentProcessing(orderId: orderId));

      final isValid = _paymentRepository.validateVNPayResponse(event.queryParameters);
      print('Signature validation result: $isValid');      if (isValid) {
        final responseCode = event.queryParameters['vnp_ResponseCode'];
        print('VNPay response code: $responseCode');
          if (responseCode == '00') {
          print('Payment successful, processing...');
          // Payment successful - use processSuccessfulPayment
          final invoice = await _paymentRepository.getInvoice(orderId);
          if (invoice != null) {              // Lưu response VNPAY vào Firestore
            try {
              print('PaymentBloc - Saving VNPay response for invoiceId: $orderId, userId: ${invoice.userId}');
              print('PaymentBloc - VNPay parameters: ${event.queryParameters}');
              
              await _paymentRepository.saveVnPaymentResponse(
                invoiceId: orderId,
                userId: invoice.userId,
                vnpResponse: Map<String, dynamic>.from(event.queryParameters),
              );
              print('VNPAY response saved successfully');
            } catch (e) {
              print('Error saving VNPAY response: $e');
            }
            
            print('Processing successful payment...');
            final success = await _paymentRepository.processSuccessfulPayment(
              invoiceId: orderId,
              userId: invoice.userId,
              vnpayTransactionCode: event.queryParameters['vnp_TransactionNo'],
              vnpayOrderInfo: event.queryParameters['vnp_OrderInfo'],
            );

            if (success) {
              print('Payment processed successfully');
              final updatedInvoice = await _paymentRepository.getInvoice(orderId);
              
              // Add a small delay to ensure cart clearing is processed
              await Future.delayed(const Duration(milliseconds: 1000));
              
              emit(PaymentSuccess(
                invoice: updatedInvoice!,
                transactionNo: event.queryParameters['vnp_TransactionNo'] ?? '',
                bankCode: event.queryParameters['vnp_BankCode'] ?? '',
              ));
            } else {
              emit(const PaymentFailure(error: 'Failed to process successful payment'));
            }
          } else {
            emit(const PaymentFailure(error: 'Invoice not found'));
          }
        } else {
          // Payment failed
          await _paymentRepository.updateInvoiceStatus(
            invoiceId: orderId,
            paymentStatus: 'failed',
          );
          
          emit(PaymentFailure(
            error: 'Payment failed with code: $responseCode',
            orderId: orderId,
            responseCode: responseCode,
          ));
        }
      } else {
        // Invalid signature
        await _paymentRepository.updateInvoiceStatus(
          invoiceId: orderId,
          paymentStatus: 'failed',
        );
          emit(const PaymentFailure(
          error: 'Invalid payment response signature',
        ));
      }
    } catch (error) {
      emit(PaymentFailure(error: error.toString()));
    }
  }
}
