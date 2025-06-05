import 'package:cart_repository/cart_repository.dart';
import 'models/models.dart';

/// Abstract repository interface for managing payment operations.
///
/// This repository provides methods for handling payments, invoices,
/// and invoice details with VNPAY integration.
abstract class PaymentRepository {
  /// Creates a new invoice and invoice details from cart items.
  ///
  /// Returns the created [Invoice] object.
  /// Throws an exception if the operation fails.
  Future<Invoice> createInvoice({
    required String userId,
    required List<CartItem> cartItems,
    required String paymentMethod,
  });
  
  /// Updates invoice payment status.
  ///
  /// Updates the invoice with [invoiceId] to the new [paymentStatus].
  /// Optionally updates VNPAY transaction details.
  /// Throws an exception if the operation fails.
  Future<void> updateInvoiceStatus({
    required String invoiceId,
    required String paymentStatus,
    String? vnpayTransactionCode,
    String? vnpayOrderInfo,
  });
  
  /// Gets an invoice by ID.
  ///
  /// Returns the [Invoice] for the given [invoiceId].
  /// Returns null if not found.
  /// Throws an exception if the operation fails.
  Future<Invoice?> getInvoice(String invoiceId);
  
  /// Gets invoice details for an invoice.
  ///
  /// Returns a list of [InvoiceDetail] objects for the given [invoiceId].
  /// Returns empty list if no details found.
  /// Throws an exception if the operation fails.
  Future<List<InvoiceDetail>> getInvoiceDetails(String invoiceId);
  
  /// Gets all invoices for a user.
  ///
  /// Returns a list of [Invoice] objects for the given [userId].
  /// Returns empty list if no invoices found.
  /// Throws an exception if the operation fails.
  Future<List<Invoice>> getUserInvoices(String userId);
  /// Creates a VNPAY payment URL.
  ///
  /// [amount] should be in USD. It will be automatically converted to VND
  /// using the exchange rate of 1 USD = 25,000 VND before sending to VNPAY.
  /// Returns the payment URL string for redirecting to VNPAY.
  /// Throws an exception if the operation fails.
  Future<String> createVNPayPaymentUrl({
    required String orderId,
    required double amount, // Amount in USD
    required String orderInfo,
    required String returnUrl,
    String ipAddress = "192.168.1.1",
  });
  
  /// Validates VNPAY payment response.
  ///
  /// Returns true if the response is valid, false otherwise.
  bool validateVNPayResponse(Map<String, String> vnpParams);
  
  /// Processes successful payment.
  ///
  /// Updates invoice status to 'paid' and clears user's cart.
  /// Returns true if successful, false otherwise.
  /// Throws an exception if the operation fails.
  Future<bool> processSuccessfulPayment({
    required String invoiceId,
    required String userId,
    String? vnpayTransactionCode,
    String? vnpayOrderInfo,
  });
}
