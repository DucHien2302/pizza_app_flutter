import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../pizza_repository.dart';

class FirebasePizzaRepo implements PizzaRepo {
  final pizzaCollection = FirebaseFirestore.instance.collection('pizzas');
  final reviewsCollection = FirebaseFirestore.instance.collection('reviews');

  @override
  Future<List<Pizza>> getPizzas() async {
    try {
      return await pizzaCollection
        .get()
        .then((value) => value.docs.map((e) => 
          Pizza.fromEntity(PizzaEntity.fromDocument(e.data()))
        ).toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
  @override
  Future<List<Review>> getReviewsForPizza(String pizzaId) async {
    try {
      final querySnapshot = await reviewsCollection
        .where('pizzaId', isEqualTo: pizzaId)
        .get();
      
      final reviews = querySnapshot.docs.map((e) => 
        Review.fromEntity(ReviewEntity.fromDocument(e.data()))
      ).toList();
      
      // Sort by createdAt in descending order (newest first)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> addReview(Review review) async {
    try {
      await reviewsCollection
        .doc(review.reviewId)
        .set(review.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<double> getAverageRating(String pizzaId) async {
    try {
      final reviews = await getReviewsForPizza(pizzaId);
      if (reviews.isEmpty) return 0.0;
      
      double totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
      return totalRating / reviews.length;
    } catch (e) {
      log(e.toString());
      return 0.0;
    }
  }
  @override
  Future<int> getReviewCount(String pizzaId) async {
    try {
      final reviews = await getReviewsForPizza(pizzaId);
      return reviews.length;
    } catch (e) {
      log(e.toString());
      return 0;
    }
  }

  @override
  Future<bool> hasUserReviewed(String pizzaId, String userId) async {
    try {
      final querySnapshot = await reviewsCollection
        .where('pizzaId', isEqualTo: pizzaId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Stream for real-time reviews
  Stream<List<Review>> getReviewsStreamForPizza(String pizzaId) {
    return reviewsCollection
        .where('pizzaId', isEqualTo: pizzaId)
        .snapshots()
        .map((querySnapshot) {
      final reviews = querySnapshot.docs.map((e) =>
          Review.fromEntity(ReviewEntity.fromDocument(e.data()))).toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }
}