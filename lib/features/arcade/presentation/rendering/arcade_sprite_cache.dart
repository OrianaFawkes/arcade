import 'dart:ui' as ui;

import 'arcade_pixel_sprite_painter.dart';
import 'arcade_sprite_registry.dart';

class ArcadeSpriteCache {
  Future<void>? _initialization;

  ArcadeSpriteCache._();

  static final ArcadeSpriteCache instance = ArcadeSpriteCache._();

  final Map<String, ui.Image> _images = {};

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    for (final entry in ArcadeSpriteRegistry.sprites.entries) {
      if (_images.containsKey(entry.key)) continue;

      final pixels = entry.value;

      if (pixels.isEmpty || pixels.first.isEmpty) {
        throw StateError('Sprite "${entry.key}" has no pixels.');
      }

      final height = pixels.length;
      final width = pixels.first.length;

      if (pixels.any((row) => row.length != width)) {
        throw StateError('Sprite "${entry.key}" has inconsistent row lengths.');
      }

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      drawPixelSprite(
        canvas,
        pixels,
        ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      );

      final picture = recorder.endRecording();

      try {
        _images[entry.key] = await picture.toImage(width, height);
      } finally {
        picture.dispose();
      }
    }
  }

  ui.Image? imageFor(String spriteId) => _images[spriteId];

  bool get isInitialized =>
      _images.length == ArcadeSpriteRegistry.sprites.length;

  void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }

    _images.clear();
    _initialization = null;
  }
}
