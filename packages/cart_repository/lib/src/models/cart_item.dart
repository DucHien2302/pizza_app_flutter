import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart';
import '../entities/entities.dart';

/// Represents an item in a user's shopping cart.
/// 
/// A [CartItem] contains a reference to a [Pizza] object along with
/// the quantity selected by the user and timestamp information.
class CartItem extends Equatable {
  /// The ID of the user who owns this cart item.
  final String userId;
  
  /// The pizza object associated with this cart item.
  final Pizza pizza;
  
  /// The quantity of this pizza in the cart.
  final int quantity;
  
  /// When this cart item was originally created.
  final DateTime createdAt;
  
  /// When this cart item was last updated.
  final DateTime updatedAt;
  const CartItem({
    required this.userId,
    required this.pizza,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// An empty cart item used as a default value.
  static final empty = CartItem(
    userId: '',
    pizza: Pizza.empty,
    quantity: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Creates a copy of this cart item with the given fields replaced.
  CartItem copyWith({
    String? userId,
    Pizza? pizza,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      userId: userId ?? this.userId,
      pizza: pizza ?? this.pizza,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Returns true if this cart item is empty (default values).
  bool get isEmpty => userId.isEmpty && pizza.pizzaId.isEmpty && quantity == 0;

  /// Returns true if this cart item is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Converts this cart item to a [CartEntity] for database storage.
  CartEntity toEntity() {
    return CartEntity(
      userId: userId,
      pizzaId: pizza.pizzaId,
      quantity: quantity,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [CartItem] from a [CartEntity] and [Pizza] object.
  static CartItem fromEntity(CartEntity entity, Pizza pizza) {
    return CartItem(
      userId: entity.userId,
      pizza: pizza,
      quantity: entity.quantity,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Calculates the total price for this cart item including discounts.
  double get totalPrice {
    final discountedPrice = pizza.price - (pizza.price * (pizza.discount / 100));
    return discountedPrice * quantity;
  }

  @override
  List<Object?> get props => [userId, pizza, quantity, createdAt, updatedAt];

  @override
  String toString() {
    return '''CartItem: {
      userId: $userId,
      pizza: $pizza,
      quantity: $quantity,
      createdAt: $createdAt,
      updatedAt: $updatedAt
    }''';
  }
}
