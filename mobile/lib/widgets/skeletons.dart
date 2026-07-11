import 'package:flutter/material.dart';

import '../theme.dart';

/// Loading placeholders shaped like the real cards so lists don't jump
/// when content arrives. Pulses gently; stays static when the platform
/// asks for reduced motion.
class SkeletonList extends StatefulWidget {
  final int count;
  final Widget Function() itemBuilder;

  const SkeletonList({super.key, this.count = 5, required this.itemBuilder});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final list = ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.count,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => widget.itemBuilder(),
    );
    if (reduceMotion) return Opacity(opacity: 0.7, child: list);
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 0.9).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: list,
    );
  }
}

Widget _bar({required double width, double height = 12, double radius = 6}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Palette.periWell,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Mirrors BeanCard's layout: title, roaster, tag row.
class BeanCardSkeleton extends StatelessWidget {
  const BeanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(width: 180, height: 14),
            const SizedBox(height: 8),
            _bar(width: 120),
            const SizedBox(height: 12),
            Row(
              children: [
                _bar(width: 64, height: 22, radius: 11),
                const SizedBox(width: 6),
                _bar(width: 76, height: 22, radius: 11),
                const SizedBox(width: 6),
                _bar(width: 56, height: 22, radius: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the journal brew card: bean name, date, parameter row.
class BrewCardSkeleton extends StatelessWidget {
  const BrewCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bar(width: 150, height: 14),
                _bar(width: 70),
              ],
            ),
            const SizedBox(height: 10),
            _bar(width: 220),
            const SizedBox(height: 8),
            _bar(width: 170),
          ],
        ),
      ),
    );
  }
}
