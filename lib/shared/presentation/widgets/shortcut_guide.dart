import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';
import 'package:smart_padding/smart_padding.dart';

class ShortcutGuide extends StatelessWidget {
  final String description;

  final List<String> keys;

  const ShortcutGuide({
    super.key,
    required this.description,
    required this.keys,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SmartPadding(
      vertical: 4.0,
      child: Wrap(
        runSpacing: 4.0,
        crossAxisAlignment: .center,
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) ...[
              Text(
                ' or ',
                style: textTheme.bodyMedium,
                textAlign: .start,
                overflow: .ellipsis,
                maxLines: 1,
              ),
            ],
            PixelCard(
              borderColor: Color(0xFFF2D3F2),
              fillColor: Color(0xFFF2D3F2),
              padding: .symmetric(vertical: 2.0, horizontal: 8.0),
              radius: 2,
              hasShadow: false,
              child: Text(
                keys[i],
                style: textTheme.bodySmall?.copyWith(color: Color(0xFF36343D)),
              ),
            ),
          ],
          Text(
            ' – $description',
            style: textTheme.bodyMedium,
            textAlign: .start,
            overflow: .ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
