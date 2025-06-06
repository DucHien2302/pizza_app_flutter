import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/blocs/review_bloc/review_bloc.dart';
import 'package:pizza_app/components/add_review_dialog.dart';

class ReviewDialogWrapper extends StatelessWidget {
  final String pizzaId;

  const ReviewDialogWrapper({
    Key? key,
    required this.pizzaId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(
        RepositoryProvider.of(context),
      ),
      child: BlocConsumer<ReviewBloc, ReviewState>(
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
                builder: (context) => AddReviewDialog(pizzaId: pizzaId),
              );
            }
          } else if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return const SizedBox.shrink(); // Hidden widget, logic handled in listener
        },
      ),
    );
  }

  static void show(BuildContext context, String pizzaId) {
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
    showDialog(
      context: context,
      builder: (dialogContext) => ReviewDialogWrapper(pizzaId: pizzaId),
    );

    // Trigger the check
    Future.delayed(Duration.zero, () {
      context.read<ReviewBloc>().add(CheckUserReviewEvent(pizzaId, userId));
    });
  }
}
