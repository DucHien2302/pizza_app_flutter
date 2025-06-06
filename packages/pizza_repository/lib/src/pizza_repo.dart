import 'models/models.dart';

abstract class PizzaRepo {
  Future<List<Pizza>> getPizzas();
  
  // Review methods
  Future<List<Review>> getReviewsForPizza(String pizzaId);
  Future<void> addReview(Review review);
  Future<double> getAverageRating(String pizzaId);
  Future<int> getReviewCount(String pizzaId);
  Future<bool> hasUserReviewed(String pizzaId, String userId);
  // Real-time review stream
  Stream<List<Review>> getReviewsStreamForPizza(String pizzaId);
}
