import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_repository/pizza_repository.dart';
import '../cart_repository.dart';

/// Firebase implementation of [CartRepository].
/// 
/// This implementation uses Cloud Firestore to store and manage cart data.
/// Cart items are stored in a 'carts' collection with document IDs formatted
/// as '{userId}_{pizzaId}' to ensure uniqueness and enable efficient queries.
class FirebaseCartRepository implements CartRepository {
  /// Firestore collection reference for cart items.
  final cartCollection = FirebaseFirestore.instance.collection('carts');
  
  /// Firestore collection reference for pizza data.
  final pizzaCollection = FirebaseFirestore.instance.collection('pizzas');

  @override
  Stream<List<CartItem>> getCartItems(String userId) {
    try {
      return cartCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .asyncMap((snapshot) async {
        List<CartItem> cartItems = [];
        
        for (var doc in snapshot.docs) {
          try {
            final cartEntity = CartEntity.fromDocument(doc.data());
            
            // Get pizza data
            final pizzaDoc = await pizzaCollection.doc(cartEntity.pizzaId).get();
            if (pizzaDoc.exists) {
              final pizza = Pizza.fromEntity(
                PizzaEntity.fromDocument(pizzaDoc.data()!)
              );
              cartItems.add(CartItem.fromEntity(cartEntity, pizza));
            }
          } catch (e) {
            log('Error processing cart item: $e');
          }
        }
        
        return cartItems;
      });
    } catch (e) {
      log('Error getting cart items: $e');
      rethrow;
    }
  }

  @override
  Future<void> addToCart(CartItem cartItem) async {
    try {
      final docId = '${cartItem.userId}_${cartItem.pizza.pizzaId}';
      
      // Check if item already exists
      final existingDoc = await cartCollection.doc(docId).get();
      
      if (existingDoc.exists) {
        // Update quantity
        final existingData = existingDoc.data()!;
        final existingQuantity = existingData['quantity'] as int;
        await cartCollection.doc(docId).update({
          'quantity': existingQuantity + cartItem.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        await cartCollection.doc(docId).set({
          ...cartItem.toEntity().toDocument(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      log('Error adding to cart: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCartItem(CartItem cartItem) async {
    try {
      final docId = '${cartItem.userId}_${cartItem.pizza.pizzaId}';
      
      if (cartItem.quantity <= 0) {
        // Remove item if quantity is 0 or less
        await removeFromCart(cartItem.userId, cartItem.pizza.pizzaId);
      } else {
        // Update quantity
        await cartCollection.doc(docId).update({
          'quantity': cartItem.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      log('Error updating cart item: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFromCart(String userId, String pizzaId) async {
    try {
      final docId = '${userId}_$pizzaId';
      await cartCollection.doc(docId).delete();
    } catch (e) {
      log('Error removing from cart: $e');
      rethrow;
    }
  }
  @override
  Future<void> clearCart(String userId) async {
    try {
      print('Clearing cart for user: $userId');
      final batch = FirebaseFirestore.instance.batch();
      final cartDocs = await cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      print('Found ${cartDocs.docs.length} cart items to delete');
      
      for (var doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Cart cleared successfully for user: $userId');
    } catch (e) {
      log('Error clearing cart: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCartItemCount(String userId) async {
    try {
      final cartDocs = await cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      int totalCount = 0;
      for (var doc in cartDocs.docs) {
        totalCount += (doc.data()['quantity'] as int);
      }
      
      return totalCount;
    } catch (e) {
      log('Error getting cart item count: $e');
      rethrow;
    }
  }

  @override
  Future<double> getTotalCartPrice(String userId) async {
    try {
      final cartDocs = await cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      double totalPrice = 0.0;
      
      for (var doc in cartDocs.docs) {
        final cartData = doc.data();
        final pizzaId = cartData['pizzaId'] as String;
        final quantity = cartData['quantity'] as int;
        
        // Get pizza data to calculate price
        final pizzaDoc = await pizzaCollection.doc(pizzaId).get();
        if (pizzaDoc.exists) {
          final pizzaData = pizzaDoc.data()!;
          final price = (pizzaData['price'] as num).toDouble();
          final discount = (pizzaData['discount'] as num).toDouble();
          
          final discountedPrice = price - (price * (discount / 100));
          totalPrice += discountedPrice * quantity;
        }
      }
      
      return totalPrice;
    } catch (e) {
      log('Error getting total cart price: $e');
      rethrow;
    }
  }
}
