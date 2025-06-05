import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cart_repository/cart_repository.dart';
import 'package:uuid/uuid.dart';
import '../payment_repository.dart';

class FirebasePaymentRepository implements PaymentRepository {
  final invoicesCollection = FirebaseFirestore.instance.collection('invoices');
  final invoiceDetailsCollection = FirebaseFirestore.instance.collection('invoice_details');
  final vnPaymentResponsesCollection = FirebaseFirestore.instance.collection('vn_payment_responses');
  
  final CartRepository _cartRepository;
  final _uuid = const Uuid();
  late final VNPayService _vnPayService;
  
  FirebasePaymentRepository({
    required CartRepository cartRepository,
  }) : _cartRepository = cartRepository {
    const vnPayConfig = VNPayConfig(
      version: '2.1.0',
      command: 'pay',
      currCode: 'VND',
      locale: 'vn',
      orderType: 'other',
      tmnCode: 'HC3JP794',
      hashSecret: 'TGU6RJ2H7T10Z58R4JJVD7NVLM913CMN',
      url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
    );
    _vnPayService = VNPayService(config: vnPayConfig);
  }

  @override
  Future<Invoice> createInvoice({
    required String userId,
    required List<CartItem> cartItems,
    required String paymentMethod,
  }) async {
    try {
      final invoiceId = _uuid.v4();
      final now = DateTime.now();
      
      // Tính tổng tiền
      double totalAmount = 0.0;
      for (final item in cartItems) {
        totalAmount += item.totalPrice;
      }
      
      // Tạo invoice
      final invoice = Invoice(
        invoiceId: invoiceId,
        userId: userId,
        totalAmount: totalAmount,
        paymentStatus: 'pending',
        paymentMethod: paymentMethod,
        createdAt: now,
        updatedAt: now,
      );
      
      // Lưu invoice vào Firestore
      await invoicesCollection.doc(invoiceId).set({
        ...invoice.toEntity().toDocument(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Tạo invoice details
      final batch = FirebaseFirestore.instance.batch();
      
      for (final item in cartItems) {
        final detailId = _uuid.v4();
        final detail = InvoiceDetail(
          invoiceDetailId: detailId,
          invoiceId: invoiceId,
          pizzaId: item.pizza.pizzaId,
          pizzaName: item.pizza.name,
          pizzaPrice: item.pizza.price.toDouble(),
          discount: item.pizza.discount.toDouble(),
          quantity: item.quantity,
          totalPrice: item.totalPrice,
          createdAt: now,
        );
        
        batch.set(
          invoiceDetailsCollection.doc(detailId),
          {
            ...detail.toEntity().toDocument(),
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }
      
      await batch.commit();
      
      return invoice;
    } catch (e) {
      log('Error creating invoice: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateInvoiceStatus({
    required String invoiceId,
    required String paymentStatus,
    String? vnpayTransactionCode,
    String? vnpayOrderInfo,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (vnpayTransactionCode != null) {
        updateData['vnpayTransactionCode'] = vnpayTransactionCode;
      }
      
      if (vnpayOrderInfo != null) {
        updateData['vnpayOrderInfo'] = vnpayOrderInfo;
      }
      
      await invoicesCollection.doc(invoiceId).update(updateData);
    } catch (e) {
      log('Error updating invoice status: $e');
      rethrow;
    }
  }

  @override
  Future<Invoice?> getInvoice(String invoiceId) async {
    try {
      final doc = await invoicesCollection.doc(invoiceId).get();
      if (doc.exists && doc.data() != null) {
        return Invoice.fromEntity(
          InvoiceEntity.fromDocument(doc.data()!)
        );
      }
      return null;
    } catch (e) {
      log('Error getting invoice: $e');
      rethrow;
    }
  }

  @override
  Future<List<InvoiceDetail>> getInvoiceDetails(String invoiceId) async {
    try {
      final querySnapshot = await invoiceDetailsCollection
          .where('invoiceId', isEqualTo: invoiceId)
          .orderBy('createdAt')
          .get();
      
      return querySnapshot.docs.map((doc) => 
        InvoiceDetail.fromEntity(
          InvoiceDetailEntity.fromDocument(doc.data())
        )
      ).toList();
    } catch (e) {
      log('Error getting invoice details: $e');
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> getUserInvoices(String userId) async {
    try {
      final querySnapshot = await invoicesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) => 
        Invoice.fromEntity(
          InvoiceEntity.fromDocument(doc.data())
        )
      ).toList();
    } catch (e) {
      log('Error getting user invoices: $e');
      rethrow;
    }
  }  @override
  Future<String> createVNPayPaymentUrl({    
    required String orderId,
    required double amount, // Amount in USD, will be converted to VND in VNPay service
    required String orderInfo,
    required String returnUrl,
    String ipAddress = "192.168.1.1",
  }) async {
    try {
      return _vnPayService.createPaymentUrl(
        orderId: orderId,
        amount: amount,
        orderInfo: orderInfo,
        returnUrl: returnUrl,
        ipAddress: ipAddress,
      );
    } catch (e) {
      log('Error creating VNPAY payment URL: $e');
      rethrow;
    }
  }
  @override
  bool validateVNPayResponse(Map<String, String> vnpParams) {
    try {
      return _vnPayService.validateResponse(vnpParams);
    } catch (e) {
      log('Error validating VNPAY response: $e');
      return false;
    }
  }
  @override
  Future<bool> processSuccessfulPayment({
    required String invoiceId,
    required String userId,
    String? vnpayTransactionCode,
    String? vnpayOrderInfo,
  }) async {
    try {
      // Cập nhật trạng thái invoice thành 'paid'
      await updateInvoiceStatus(
        invoiceId: invoiceId,
        paymentStatus: 'paid',
        vnpayTransactionCode: vnpayTransactionCode,
        vnpayOrderInfo: vnpayOrderInfo,
      );
      
      // Xóa giỏ hàng với retry logic
      await _clearCartWithRetry(userId);
      
      return true;
    } catch (e) {
      log('Error processing successful payment: $e');
      return false;
    }
  }

  Future<void> _clearCartWithRetry(String userId, {int retryCount = 3}) async {
    for (int i = 0; i < retryCount; i++) {
      try {
        await _cartRepository.clearCart(userId);
        
        // Verify cart is actually cleared
        final items = await _cartRepository.getCartItems(userId).first;
        if (items.isEmpty) {
          log('Cart cleared successfully for user: $userId');
          return;
        } else {
          log('Cart not cleared completely, retrying... Attempt ${i + 1}');
          if (i == retryCount - 1) {
            throw Exception('Failed to clear cart after $retryCount attempts');
          }
          await Future.delayed(Duration(milliseconds: 500));
        }
      } catch (e) {
        log('Error clearing cart (attempt ${i + 1}): $e');
        if (i == retryCount - 1) rethrow;
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
  }  @override
  Future<void> saveVnPaymentResponse({
    required String invoiceId,
    required String userId,
    required Map<String, dynamic> vnpResponse,
  }) async {
    try {
      log('FirebasePaymentRepository - Saving VNPay response for invoiceId: $invoiceId, userId: $userId');
      log('FirebasePaymentRepository - VNPay response data: $vnpResponse');
      
      // Use invoiceId as document ID for easier retrieval
      await vnPaymentResponsesCollection.doc(invoiceId).set({
        'invoiceId': invoiceId,
        'userId': userId,
        'vnpResponse': vnpResponse,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      log('FirebasePaymentRepository - VNPay response saved with document ID: $invoiceId');
    } catch (e) {
      log('Error saving VNPAY response: $e');
      rethrow;
    }
  }
}
