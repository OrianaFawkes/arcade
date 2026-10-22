import 'dart:ui';

void drawPixelSprite(Canvas canvas, List<List<int>> pixels, Rect destination) {
  if (pixels.isEmpty || pixels.first.isEmpty) return;

  final height = pixels.length;
  final width = pixels.first.length;

  final pixelWidth = destination.width / width;
  final pixelHeight = destination.height / height;

  final paint = Paint()
    ..style = .fill
    ..isAntiAlias = false;

  for (var y = 0; y < height; y++) {
    assert(pixels[y].length == width);

    for (var x = 0; x < width; x++) {
      final argb = pixels[y][x];

      // Zero represents a fully transparent pixel.
      if (argb == 0) continue;

      paint.color = Color(argb);

      canvas.drawRect(
        Rect.fromLTWH(
          destination.left + x * pixelWidth,
          destination.top + y * pixelHeight,
          pixelWidth,
          pixelHeight,
        ),
        paint,
      );
    }
  }
}
