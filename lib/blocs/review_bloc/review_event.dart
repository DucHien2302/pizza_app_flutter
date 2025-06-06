part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class GetReviewsEvent extends ReviewEvent {
  final String pizzaId;

  const GetReviewsEvent(this.pizzaId);

  @override
  List<Object> get props => [pizzaId];
}

class AddReviewEvent extends ReviewEvent {
  final Review review;

  const AddReviewEvent(this.review);

  @override
  List<Object> get props => [review];
}

class RefreshReviewsEvent extends ReviewEvent {
  final String pizzaId;

  const RefreshReviewsEvent(this.pizzaId);

  @override
  List<Object> get props => [pizzaId];
}

class CheckUserReviewEvent extends ReviewEvent {
  final String pizzaId;
  final String userId;

  const CheckUserReviewEvent(this.pizzaId, this.userId);

  @override
  List<Object> get props => [pizzaId, userId];
}
