import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  final String label;

  final Color? color;

  final VoidCallback? onTap;

  const TextLink({
    super.key,
    required this.label,
    this.color = const Color(0xFFF2D3F2),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: color,
            decoration: .underline,
            decorationColor: color,
          ),
          textAlign: .start,
          overflow: .ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
