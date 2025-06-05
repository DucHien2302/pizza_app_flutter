import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity class for storing invoice data in Firestore.
class InvoiceEntity extends Equatable {
  /// Unique invoice ID
  final String invoiceId;
  
  /// User ID who made the order
  final String userId;
  
  /// Total amount of the invoice
  final double totalAmount;
  
  /// Payment status (pending, paid, failed, cancelled)
  final String paymentStatus;
  
  /// Payment method (vnpay, cash, etc.)
  final String paymentMethod;
  
  /// VNPAY transaction code
  final String? vnpayTransactionCode;
  
  /// VNPAY order info
  final String? vnpayOrderInfo;
  
  /// When this invoice was created
  final DateTime createdAt;
  
  /// When this invoice was last updated
  final DateTime updatedAt;
  
  const InvoiceEntity({
    required this.invoiceId,
    required this.userId,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.vnpayTransactionCode,
    this.vnpayOrderInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts this entity to a Map for Firestore storage.
  Map<String, Object?> toDocument() {
    return {
      'invoiceId': invoiceId,
      'userId': userId,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'vnpayTransactionCode': vnpayTransactionCode,
      'vnpayOrderInfo': vnpayOrderInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  
  /// Creates an [InvoiceEntity] from Firestore document data.
  static InvoiceEntity fromDocument(Map<String, dynamic> doc) {
    return InvoiceEntity(
      invoiceId: doc['invoiceId'] as String,
      userId: doc['userId'] as String,
      totalAmount: (doc['totalAmount'] as num).toDouble(),
      paymentStatus: doc['paymentStatus'] as String,
      paymentMethod: doc['paymentMethod'] as String,
      vnpayTransactionCode: doc['vnpayTransactionCode'] as String?,
      vnpayOrderInfo: doc['vnpayOrderInfo'] as String?,
      createdAt: doc['createdAt'] is Timestamp 
          ? (doc['createdAt'] as Timestamp).toDate()
          : doc['createdAt'] is DateTime 
              ? doc['createdAt'] as DateTime
              : DateTime.now(),
      updatedAt: doc['updatedAt'] is Timestamp 
          ? (doc['updatedAt'] as Timestamp).toDate()
          : doc['updatedAt'] is DateTime 
              ? doc['updatedAt'] as DateTime
              : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    invoiceId, userId, totalAmount, paymentStatus, paymentMethod,
    vnpayTransactionCode, vnpayOrderInfo, createdAt, updatedAt
  ];

  @override
  String toString() {
    return '''InvoiceEntity: {
      invoiceId: $invoiceId,
      userId: $userId,
      totalAmount: $totalAmount,
      paymentStatus: $paymentStatus,
      paymentMethod: $paymentMethod,
      vnpayTransactionCode: $vnpayTransactionCode,
      vnpayOrderInfo: $vnpayOrderInfo,
      createdAt: $createdAt,
      updatedAt: $updatedAt
    }''';
  }
}
