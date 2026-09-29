import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarBar extends StatelessWidget {
  final double rating;

  const StarBar({
    Key? key,
    required this.rating,
  }) : super(key: key);

  void _saveRating(double rating) {
    print("New rating: $rating");
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      itemSize: 55,
      minRating: 0,
      maxRating: 5,
      allowHalfRating: true,
      onRatingUpdate: _saveRating,
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star, color: Colors.amber),
        half: const Icon(Icons.star_half, color: Colors.amber),
        empty: const Icon(Icons.star_border,
        color: Color.fromARGB(255, 255, 255, 255)),
      )
    );
  }
}