import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/blocs/review_bloc/review_bloc.dart';
import 'package:pizza_app/components/add_review_dialog.dart';
import 'package:pizza_app/components/review_item.dart';
import 'package:pizza_app/components/star_rating.dart';
import 'package:pizza_repository/pizza_repository.dart';

class ReviewsScreen extends StatelessWidget {
  final Pizza pizza;

  const ReviewsScreen({
    Key? key,
    required this.pizza,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(
        RepositoryProvider.of<PizzaRepo>(context),
      )..add(GetReviewsEvent(pizza.pizzaId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Đánh giá - ${pizza.name}'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),        body: BlocListener<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state is UserReviewChecked) {
              if (state.hasReviewed) {
                // User has already reviewed, show message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bạn đã đánh giá pizza này rồi!'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                // User hasn't reviewed, show dialog
                showDialog(
                  context: context,
                  builder: (dialogContext) => BlocProvider.value(
                    value: context.read<ReviewBloc>(),
                    child: AddReviewDialog(pizzaId: pizza.pizzaId),
                  ),
                );
              }
            }
          },
          child: BlocBuilder<ReviewBloc, ReviewState>(
            builder: (context, state) {
            if (state is ReviewLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ReviewError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReviewBloc>().add(
                          GetReviewsEvent(pizza.pizzaId),
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            } else if (state is ReviewLoaded) {
              return Column(
                children: [
                  // Rating summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đánh giá trung bình',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    state.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StarRating(
                                    rating: state.averageRating,
                                    size: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.reviewCount} đánh giá',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),                        ElevatedButton.icon(
                          onPressed: () => _showAddReviewDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm đánh giá'),
                        ),
                      ],
                    ),
                  ),
                  
                  // Reviews list
                  Expanded(
                    child: state.reviews.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Chưa có đánh giá nào',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Hãy là người đầu tiên đánh giá pizza này!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<ReviewBloc>().add(
                                RefreshReviewsEvent(pizza.pizzaId),
                              );
                            },
                            child: ListView.builder(
                              itemCount: state.reviews.length,
                              itemBuilder: (context, index) {
                                return ReviewItem(
                                  review: state.reviews[index],
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }
              return const Center(
              child: Text('Không có dữ liệu'),
            );
          },
        ),
      ),
    ),
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status != AuthenticationStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đánh giá!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = authState.user?.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xác định người dùng!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // First check if user has already reviewed
    context.read<ReviewBloc>().add(CheckUserReviewEvent(pizza.pizzaId, userId));
  }
}
