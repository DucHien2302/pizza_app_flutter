import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool allowHalfRating;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 20.0,
    this.color = Colors.amber,
    this.allowHalfRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = allowHalfRating && (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    // Full stars
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(
        Icons.star,
        size: size,
        color: color,
      ));
    }

    // Half star
    if (hasHalfStar) {
      stars.add(Icon(
        Icons.star_half,
        size: size,
        color: color,
      ));
    }

    // Empty stars
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(
        Icons.star_border,
        size: size,
        color: color,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;
  final Color color;

  const InteractiveStarRating({
    Key? key,
    required this.onRatingChanged,
    this.initialRating = 0.0,
    this.size = 30.0,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0;
            });
            widget.onRatingChanged(_rating);
          },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            size: widget.size,
            color: widget.color,
          ),
        );
      }),
    );
  }
}
