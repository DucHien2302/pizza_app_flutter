import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cart_repository/cart_repository.dart';
import 'package:uuid/uuid.dart';
import '../payment_repository.dart';

class FirebasePaymentRepository implements PaymentRepository {
  final invoicesCollection = FirebaseFirestore.instance.collection('invoices');
  final invoiceDetailsCollection = FirebaseFirestore.instance.collection('invoice_details');
  
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
      
      // Xóa giỏ hàng
      await _cartRepository.clearCart(userId);
      
      return true;
    } catch (e) {
      log('Error processing successful payment: $e');
      return false;
    }
  }
}
