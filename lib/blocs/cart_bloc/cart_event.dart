part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  final String userId;

  const LoadCart({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CartUpdated extends CartEvent {
  final List<CartItem> items;

  const CartUpdated({required this.items});

  @override
  List<Object?> get props => [items];
}

class AddToCart extends CartEvent {
  final String userId;
  final Pizza pizza;
  final int quantity;

  const AddToCart({
    required this.userId,
    required this.pizza, 
    this.quantity = 1
  });

  @override
  List<Object?> get props => [userId, pizza, quantity];
}

class RemoveFromCart extends CartEvent {
  final String userId;
  final String pizzaId;

  const RemoveFromCart({required this.userId, required this.pizzaId});

  @override
  List<Object?> get props => [userId, pizzaId];
}

class UpdateQuantity extends CartEvent {
  final String userId;
  final String pizzaId;
  final int quantity;

  const UpdateQuantity({
    required this.userId,
    required this.pizzaId, 
    required this.quantity
  });

  @override
  List<Object?> get props => [userId, pizzaId, quantity];
}

class ClearCart extends CartEvent {
  final String userId;

  const ClearCart({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshCart extends CartEvent {
  final String userId;

  const RefreshCart({required this.userId});

  @override
  List<Object?> get props => [userId];
}
