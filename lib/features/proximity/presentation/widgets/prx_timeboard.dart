import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

class PrxTimeboard extends StatelessWidget {
  final String gameStatus;
  final String difficulty;
  final String elapsedTime;
  final String bestTime;

  const PrxTimeboard({
    super.key,
    required this.gameStatus,
    required this.difficulty,
    required this.elapsedTime,
    required this.bestTime,
  });

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
              label: 'Elapsed Time\n($gameStatus)',
              value: elapsedTime,
            ),
          ),
          Expanded(
            child: _ScoreboardCard(
              label: 'Best Time\n($difficulty)',
              value: bestTime,
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
            textAlign: .center,
            overflow: .ellipsis,
            maxLines: 2,
          ),
          Text(
            value,
            style: textTheme.bodyLarge,
            textAlign: .center,
            overflow: .ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
