import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

class PotScoreboard extends StatelessWidget {
  final int score;
  final int best;

  const PotScoreboard({super.key, required this.score, required this.best});

  @override
  Widget build(_) {
    return SizedBox(
      width: 320.0,
      child: Row(
        mainAxisSize: .min,
        spacing: 8.0,
        children: [
          Expanded(
            child: _ScoreboardCard(
              label: 'Score:',
              value: '$score'.padLeft(9, '0'),
            ),
          ),
          Expanded(
            child: _ScoreboardCard(
              label: 'Best:',
              value: '$best'.padLeft(9, '0'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreboardCard extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreboardCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PixelCard(
      borderColor: Color(0xFFF2D3F2),
      fillColor: Color(0xFF36343D),
      padding: .symmetric(vertical: 4.0, horizontal: 8.0),
      hasShadow: false,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Text(
            label,
            style: textTheme.bodySmall,
            textAlign: .start,
            overflow: .ellipsis,
            maxLines: 1,
          ),
          Text(
            value,
            style: textTheme.bodyLarge,
            textAlign: .end,
            overflow: .ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
