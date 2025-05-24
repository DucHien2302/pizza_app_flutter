/// A Flutter package for managing shopping cart functionality.
/// 
/// This package provides a repository pattern implementation for handling
/// cart operations including adding, updating, and removing items from
/// a user's shopping cart. It includes Firebase Firestore integration
/// for data persistence.
/// 
/// Main classes:
/// - [CartRepository]: Abstract interface for cart operations
/// - [FirebaseCartRepository]: Firestore implementation
/// - [CartItem]: Model representing a cart item
/// - [CartEntity]: Entity for database persistence
library cart_repository;

export 'src/cart_repo.dart';
export 'src/firebase_cart_repo.dart';
export 'src/models/models.dart';
export 'src/entities/entities.dart';
