import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity class for storing invoice detail data in Firestore.
class InvoiceDetailEntity extends Equatable {
  /// Unique invoice detail ID
  final String invoiceDetailId;
  
  /// Invoice ID this detail belongs to
  final String invoiceId;
  
  /// Pizza ID
  final String pizzaId;
  
  /// Pizza name at the time of purchase
  final String pizzaName;
  
  /// Pizza price at the time of purchase
  final double pizzaPrice;
  
  /// Discount percentage at the time of purchase
  final double discount;
  
  /// Quantity ordered
  final int quantity;
  
  /// Total price for this line item
  final double totalPrice;
  
  /// When this detail was created
  final DateTime createdAt;
  
  const InvoiceDetailEntity({
    required this.invoiceDetailId,
    required this.invoiceId,
    required this.pizzaId,
    required this.pizzaName,
    required this.pizzaPrice,
    required this.discount,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
  });

  /// Converts this entity to a Map for Firestore storage.
  Map<String, Object?> toDocument() {
    return {
      'invoiceDetailId': invoiceDetailId,
      'invoiceId': invoiceId,
      'pizzaId': pizzaId,
      'pizzaName': pizzaName,
      'pizzaPrice': pizzaPrice,
      'discount': discount,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'createdAt': createdAt,
    };
  }
  
  /// Creates an [InvoiceDetailEntity] from Firestore document data.
  static InvoiceDetailEntity fromDocument(Map<String, dynamic> doc) {
    return InvoiceDetailEntity(
      invoiceDetailId: doc['invoiceDetailId'] as String,
      invoiceId: doc['invoiceId'] as String,
      pizzaId: doc['pizzaId'] as String,
      pizzaName: doc['pizzaName'] as String,
      pizzaPrice: (doc['pizzaPrice'] as num).toDouble(),
      discount: (doc['discount'] as num).toDouble(),
      quantity: doc['quantity'] as int,
      totalPrice: (doc['totalPrice'] as num).toDouble(),
      createdAt: doc['createdAt'] is Timestamp 
          ? (doc['createdAt'] as Timestamp).toDate()
          : doc['createdAt'] is DateTime 
              ? doc['createdAt'] as DateTime
              : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    invoiceDetailId, invoiceId, pizzaId, pizzaName, 
    pizzaPrice, discount, quantity, totalPrice, createdAt
  ];

  @override
  String toString() {
    return '''InvoiceDetailEntity: {
      invoiceDetailId: $invoiceDetailId,
      invoiceId: $invoiceId,
      pizzaId: $pizzaId,
      pizzaName: $pizzaName,
      pizzaPrice: $pizzaPrice,
      discount: $discount,
      quantity: $quantity,
      totalPrice: $totalPrice,
      createdAt: $createdAt
    }''';
  }
}
