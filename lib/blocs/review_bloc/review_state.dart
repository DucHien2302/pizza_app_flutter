part of 'review_bloc.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<Review> reviews;
  final double averageRating;
  final int reviewCount;

  const ReviewLoaded({
    required this.reviews,
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  List<Object> get props => [reviews, averageRating, reviewCount];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}

class ReviewAdding extends ReviewState {}

class ReviewAdded extends ReviewState {}

class ReviewAddError extends ReviewState {
  final String message;

  const ReviewAddError(this.message);

  @override
  List<Object> get props => [message];
}

class UserReviewChecked extends ReviewState {
  final bool hasReviewed;

  const UserReviewChecked(this.hasReviewed);

  @override
  List<Object> get props => [hasReviewed];
}
