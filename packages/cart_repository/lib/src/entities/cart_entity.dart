import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity class for storing cart data in Firestore.
/// 
/// This class represents the data structure used to persist cart items
/// in Cloud Firestore. It contains only the essential data without
/// the full [Pizza] object, which is fetched separately.
class CartEntity extends Equatable {
  /// The ID of the user who owns this cart item.
  final String userId;
  
  /// The ID of the pizza in this cart item.
  final String pizzaId;
  
  /// The quantity of this pizza in the cart.
  final int quantity;
  
  /// When this cart item was originally created.
  final DateTime createdAt;
  
  /// When this cart item was last updated.
  final DateTime updatedAt;
  const CartEntity({
    required this.userId,
    required this.pizzaId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts this entity to a Map for Firestore storage.
  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'pizzaId': pizzaId,
      'quantity': quantity,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  
  /// Creates a [CartEntity] from Firestore document data.
  /// 
  /// Handles both [Timestamp] and [DateTime] objects for date fields
  /// to ensure compatibility with different data sources.
  static CartEntity fromDocument(Map<String, dynamic> doc) {
    return CartEntity(
      userId: doc['userId'] as String,
      pizzaId: doc['pizzaId'] as String,
      quantity: doc['quantity'] as int,
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
  List<Object?> get props => [userId, pizzaId, quantity, createdAt, updatedAt];

  @override
  String toString() {
    return '''CartEntity: {
      userId: $userId,
      pizzaId: $pizzaId,
      quantity: $quantity,
      createdAt: $createdAt,
      updatedAt: $updatedAt
    }''';
  }
}
