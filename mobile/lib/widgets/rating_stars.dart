import 'package:flutter/material.dart';

import '../theme.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        final star = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: filled ? CobraColors.amber : CobraColors.textMuted,
        );
        if (onChanged == null) return star;
        return IconButton(
          onPressed: () => onChanged!(i + 1),
          icon: star,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
          tooltip: '${i + 1} star${i == 0 ? '' : 's'}',
        );
      }),
    );
  }
}
