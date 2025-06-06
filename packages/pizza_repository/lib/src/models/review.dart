import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

/// Model class representing a pizza review
class Review extends Equatable {
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

  const Review({
    required this.reviewId,
    required this.pizzaId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
  /// Empty review instance
  static final empty = Review(
    reviewId: '',
    pizzaId: '',
    userId: '',
    userName: '',
    rating: 0.0,
    comment: '',
    createdAt: DateTime.now(),
  );

  /// Converts this model to an entity for storage.
  ReviewEntity toEntity() {
    return ReviewEntity(
      reviewId: reviewId,
      pizzaId: pizzaId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }

  /// Creates a [Review] from a [ReviewEntity].
  static Review fromEntity(ReviewEntity entity) {
    return Review(
      reviewId: entity.reviewId,
      pizzaId: entity.pizzaId,
      userId: entity.userId,
      userName: entity.userName,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
    );
  }

  /// Creates a copy of this review with the given fields replaced.
  Review copyWith({
    String? reviewId,
    String? pizzaId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      reviewId: reviewId ?? this.reviewId,
      pizzaId: pizzaId ?? this.pizzaId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    reviewId, pizzaId, userId, userName, rating, comment, createdAt
  ];

  @override
  String toString() {
    return '''Review: {
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
