import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

/// Represents an invoice in the system.
class Invoice extends Equatable {
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
  
  const Invoice({
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

  /// An empty invoice used as a default value.
  static final empty = Invoice(
    invoiceId: '',
    userId: '',
    totalAmount: 0.0,
    paymentStatus: 'pending',
    paymentMethod: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Creates a copy of this invoice with the given fields replaced.
  Invoice copyWith({
    String? invoiceId,
    String? userId,
    double? totalAmount,
    String? paymentStatus,
    String? paymentMethod,
    String? vnpayTransactionCode,
    String? vnpayOrderInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      invoiceId: invoiceId ?? this.invoiceId,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vnpayTransactionCode: vnpayTransactionCode ?? this.vnpayTransactionCode,
      vnpayOrderInfo: vnpayOrderInfo ?? this.vnpayOrderInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns true if this invoice is empty (default values).
  bool get isEmpty => invoiceId.isEmpty && userId.isEmpty && totalAmount == 0.0;

  /// Returns true if this invoice is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Returns true if payment is completed.
  bool get isPaid => paymentStatus == 'paid';

  /// Returns true if payment is pending.
  bool get isPending => paymentStatus == 'pending';

  /// Returns true if payment failed.
  bool get isFailed => paymentStatus == 'failed';

  /// Returns true if payment was cancelled.
  bool get isCancelled => paymentStatus == 'cancelled';

  /// Converts this invoice to an [InvoiceEntity] for database storage.
  InvoiceEntity toEntity() {
    return InvoiceEntity(
      invoiceId: invoiceId,
      userId: userId,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      vnpayTransactionCode: vnpayTransactionCode,
      vnpayOrderInfo: vnpayOrderInfo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an [Invoice] from an [InvoiceEntity].
  static Invoice fromEntity(InvoiceEntity entity) {
    return Invoice(
      invoiceId: entity.invoiceId,
      userId: entity.userId,
      totalAmount: entity.totalAmount,
      paymentStatus: entity.paymentStatus,
      paymentMethod: entity.paymentMethod,
      vnpayTransactionCode: entity.vnpayTransactionCode,
      vnpayOrderInfo: entity.vnpayOrderInfo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    invoiceId, userId, totalAmount, paymentStatus, paymentMethod,
    vnpayTransactionCode, vnpayOrderInfo, createdAt, updatedAt
  ];

  @override
  String toString() {
    return '''Invoice: {
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
