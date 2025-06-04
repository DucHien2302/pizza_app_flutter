import 'models/models.dart';

/// Abstract repository interface for managing shopping cart operations.
/// 
/// This repository provides methods for handling cart items including
/// adding, updating, removing items and calculating totals.
abstract class CartRepository {
  /// Gets a stream of cart items for the specified user.
  /// 
  /// Returns a [Stream] that emits updates whenever the cart changes.
  /// The stream contains a list of [CartItem] objects for the given [userId].
  Stream<List<CartItem>> getCartItems(String userId);
  
  /// Adds an item to the cart.
  /// 
  /// If the item already exists in the cart, the quantities will be combined.
  /// Throws an exception if the operation fails.
  Future<void> addToCart(CartItem cartItem);
  
  /// Updates the quantity of an existing cart item.
  /// 
  /// If the quantity is set to 0 or less, the item will be removed from the cart.
  /// Throws an exception if the operation fails.
  Future<void> updateCartItem(CartItem cartItem);
  
  /// Removes a specific item from the cart.
  /// 
  /// Removes the cart item identified by [userId] and [pizzaId].
  /// Does nothing if the item doesn't exist.
  Future<void> removeFromCart(String userId, String pizzaId);
  
  /// Clears all cart items for the specified user.
  /// 
  /// Removes all items from the cart for the given [userId].
  /// Throws an exception if the operation fails.
  Future<void> clearCart(String userId);
  
  /// Gets the total number of items in the cart.
  /// 
  /// Returns the sum of all item quantities in the cart for the given [userId].
  /// Returns 0 if the cart is empty or if an error occurs.
  Future<int> getCartItemCount(String userId);
  
  /// Calculates the total price of all items in the cart.
  /// 
  /// Returns the total price including any discounts applied to individual items.
  /// Returns 0.0 if the cart is empty or if an error occurs.
  Future<double> getTotalCartPrice(String userId);
}
