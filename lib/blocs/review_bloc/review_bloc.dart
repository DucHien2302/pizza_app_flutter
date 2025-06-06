import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final PizzaRepo _pizzaRepo;

  ReviewBloc(this._pizzaRepo) : super(ReviewInitial()) {
    on<GetReviewsEvent>(_onGetReviews);
    on<AddReviewEvent>(_onAddReview);
    on<RefreshReviewsEvent>(_onRefreshReviews);
    on<CheckUserReviewEvent>(_onCheckUserReview);
  }

  Future<void> _onGetReviews(
    GetReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final reviews = await _pizzaRepo.getReviewsForPizza(event.pizzaId);
      final averageRating = await _pizzaRepo.getAverageRating(event.pizzaId);
      final reviewCount = await _pizzaRepo.getReviewCount(event.pizzaId);
      
      emit(ReviewLoaded(
        reviews: reviews,
        averageRating: averageRating,
        reviewCount: reviewCount,
      ));
    } catch (e) {
      emit(ReviewError('Failed to load reviews: ${e.toString()}'));
    }
  }

  Future<void> _onAddReview(
    AddReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewAdding());
    try {
      await _pizzaRepo.addReview(event.review);
      emit(ReviewAdded());
      
      // Refresh the reviews after adding
      add(RefreshReviewsEvent(event.review.pizzaId));
    } catch (e) {
      emit(ReviewAddError('Failed to add review: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshReviews(
    RefreshReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final reviews = await _pizzaRepo.getReviewsForPizza(event.pizzaId);
      final averageRating = await _pizzaRepo.getAverageRating(event.pizzaId);
      final reviewCount = await _pizzaRepo.getReviewCount(event.pizzaId);
      
      emit(ReviewLoaded(
        reviews: reviews,
        averageRating: averageRating,
        reviewCount: reviewCount,
      ));
    } catch (e) {
      emit(ReviewError('Failed to refresh reviews: ${e.toString()}'));
    }
  }

  Future<void> _onCheckUserReview(
    CheckUserReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final hasReviewed = await _pizzaRepo.hasUserReviewed(event.pizzaId, event.userId);
      emit(UserReviewChecked(hasReviewed));
    } catch (e) {
      emit(ReviewError('Failed to check user review: ${e.toString()}'));
    }
  }
}
