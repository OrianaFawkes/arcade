import 'package:flutter/material.dart';

class TileColorScheme {
  final String name;

  final Color baseColor;

  const TileColorScheme({required this.name, required this.baseColor});

  static const presets = [
    TileColorScheme(name: 'Orange', baseColor: Color(0xFFF28C28)),
    TileColorScheme(name: 'Red', baseColor: Color(0xFFE53935)),
    TileColorScheme(name: 'Green', baseColor: Color(0xFF43A047)),
    TileColorScheme(name: 'Blue', baseColor: Color(0xFF1E88E5)),
    TileColorScheme(name: 'Purple', baseColor: Color(0xFF8E24AA)),
    TileColorScheme(name: 'Pink', baseColor: Color(0xFFD81B60)),
    TileColorScheme(name: 'Teal', baseColor: Color(0xFF00897B)),
    TileColorScheme(name: 'Indigo', baseColor: Color(0xFF3949AB)),
  ];

  Color fillColor(int value) {
    if (value > 2048) return Color.lerp(baseColor, Color(0xFF2D1B1B), 0.65)!;

    final exponent = _log2(value);

    // 2 -> 0.0
    // 4 -> 0.1
    // ...
    // 2048 -> 1.0
    final t = (exponent - 1) / 10;

    return .lerp(Color(0xFFECCEC3), baseColor, t.clamp(0.0, 1.0))!;
  }

  Color borderColor(int value) {
    return .lerp(fillColor(value), Color(0xFF2D1B1B), 0.15)!;
  }

  Color textColor(int value) {
    final color = fillColor(value);

    return ThemeData.estimateBrightnessForColor(color) == .dark
        ? Color(0xFFECCEC3)
        : Color(0xFF2D1B1B);
  }

  int _log2(int value) {
    var exponent = 0;

    var current = value;

    while (current > 1) {
      current ~/= 2;

      exponent++;
    }

    return exponent;
  }
}
