import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Entity class for storing review data in Firestore.
class ReviewEntity extends Equatable {
  /// Unique review ID
  final String reviewId;
  
  /// Pizza ID being reviewed
  final String pizzaId;
  
  /// User ID who made the review
  final String userId;
  
  /// User name who made the review
  final String userName;
  
  /// Rating from 1 to 5 stars
  final double rating;
  
  /// Review comment
  final String comment;
  
  /// When this review was created
  final DateTime createdAt;
  
  const ReviewEntity({
    required this.reviewId,
    required this.pizzaId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Converts this entity to a Firestore document map.
  Map<String, dynamic> toDocument() {
    return {
      'reviewId': reviewId,
      'pizzaId': pizzaId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a [ReviewEntity] from a Firestore document.
  static ReviewEntity fromDocument(Map<String, dynamic> doc) {
    return ReviewEntity(
      reviewId: doc['reviewId'] ?? '',
      pizzaId: doc['pizzaId'] ?? '',
      userId: doc['userId'] ?? '',
      userName: doc['userName'] ?? '',
      rating: (doc['rating'] ?? 0.0).toDouble(),
      comment: doc['comment'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    reviewId, pizzaId, userId, userName, rating, comment, createdAt
  ];

  @override
  String toString() {
    return '''ReviewEntity: {
      reviewId: $reviewId,
      pizzaId: $pizzaId,
      userId: $userId,
      userName: $userName,
      rating: $rating,
      comment: $comment,
      createdAt: $createdAt
    }''';
  }
}
