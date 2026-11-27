import 'package:flutter/material.dart';

/// Baris "Kategori • ★ 4.5" untuk subtitle ListTile.
class CategoryRating extends StatelessWidget {
  final String category;
  final double rating;

  const CategoryRating({
    super.key,
    required this.category,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(category, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const Text(' • '),
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1)),
      ],
    );
  }
}
