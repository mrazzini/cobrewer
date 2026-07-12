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
    return BrutCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bean.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: Palette.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (bean.cuppingScore != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Palette.olive,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: Palette.ink, width: 2),
                  ),
                  child: Text(
                    bean.cuppingScore!.toStringAsFixed(
                        bean.cuppingScore! % 1 == 0 ? 0 : 2),
                    style: const TextStyle(
                      fontFamily: 'Anton',
                      color: Palette.ink,
                      fontSize: 12,
                    ),
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
            style: const TextStyle(
              color: Palette.inkSoft,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (!compact) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Tag color encodes category: blush = roast, olive = process,
                // white = tasting notes (design/DESIGN.md).
                if (bean.roastLevel != null)
                  _tag(roastLabel(bean.roastLevel), color: Palette.blush),
                if (bean.process != null)
                  _tag(processLabel(bean.process), color: Palette.olive),
                ...bean.tastingNotes.take(3).map(_tag),
                if (!bean.isVerified) _tag('community', muted: true),
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(height: 11),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: Palette.blush,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.ink, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Palette.ink, offset: Offset(3, 3)),
                  ],
                ),
                child: const Text(
                  'DIAL THIS IN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: Palette.ink,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _tag(String text, {Color color = Colors.white, bool muted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: muted ? Palette.cream : color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: muted ? Palette.inkSoft : Palette.ink, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: muted ? Palette.inkSoft : Palette.ink,
        ),
      ),
    );
  }
}
