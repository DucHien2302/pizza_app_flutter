import 'package:equatable/equatable.dart';

/// Model to store VNPAY payment response in Firestore
class VnPaymentResponse extends Equatable {
  final String invoiceId;
  final String userId;
  final Map<String, dynamic> vnpResponse;
  final DateTime createdAt;

  const VnPaymentResponse({
    required this.invoiceId,
    required this.userId,
    required this.vnpResponse,
    required this.createdAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'invoiceId': invoiceId,
      'userId': userId,
      'vnpResponse': vnpResponse,
      'createdAt': createdAt,
    };
  }

  static VnPaymentResponse fromDocument(Map<String, dynamic> doc) {
    return VnPaymentResponse(
      invoiceId: doc['invoiceId'] as String,
      userId: doc['userId'] as String,
      vnpResponse: Map<String, dynamic>.from(doc['vnpResponse'] as Map),
      createdAt: (doc['createdAt'] as DateTime),
    );
  }

  @override
  List<Object?> get props => [invoiceId, userId, vnpResponse, createdAt];
}
