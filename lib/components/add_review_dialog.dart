import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/blocs/review_bloc/review_bloc.dart';
import 'package:pizza_app/components/star_rating.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:uuid/uuid.dart';

class AddReviewDialog extends StatefulWidget {
  final String pizzaId;

  const AddReviewDialog({
    Key? key,
    required this.pizzaId,
  }) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewAdded) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đánh giá đã được thêm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewAddError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          _isSubmitting = state is ReviewAdding;
          
          return AlertDialog(
            title: const Text('Thêm đánh giá'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh giá của bạn:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: InteractiveStarRating(
                      initialRating: _rating,
                      onRatingChanged: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nhận xét (tùy chọn):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm của bạn về pizza này...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isSubmitting ? null : () {
                  Navigator.of(context).pop();
                },
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Gửi đánh giá'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitReview() {
    final authState = context.read<AuthenticationBloc>().state;
    
    if (authState.status != AuthenticationStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để đánh giá'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = authState.user;
    if (user == null) return;

    const uuid = Uuid();
    final review = Review(
      reviewId: uuid.v4(),
      pizzaId: widget.pizzaId,
      userId: user.userId,
      userName: user.name,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<ReviewBloc>().add(AddReviewEvent(review));
  }
}
