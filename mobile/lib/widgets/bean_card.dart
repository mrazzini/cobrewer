import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/models.dart';
import '../theme.dart';

class BeanCard extends StatelessWidget {
  final Bean bean;
  final VoidCallback? onTap;
  final bool compact;

  const BeanCard({super.key, required this.bean, this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bean.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Palette.cream,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (bean.cuppingScore != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      bean.cuppingScore!.toStringAsFixed(
                          bean.cuppingScore! % 1 == 0 ? 0 : 2),
                      style: const TextStyle(
                        color: Palette.blush,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (bean.roaster != null) bean.roaster!,
                  if (bean.origin != null) bean.origin!,
                ].join(' · '),
                style: const TextStyle(color: Palette.creamDim, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!compact) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _tag(roastLabel(bean.roastLevel)),
                    if (bean.process != null) _tag(processLabel(bean.process)),
                    ...bean.tastingNotes.take(3).map(_tag),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Palette.periWell,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11.5, color: Palette.cream),
      ),
    );
  }
}
