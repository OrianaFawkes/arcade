import 'package:flutter/material.dart';

ThemeData createTheme() {
  return ThemeData(
    colorScheme: .fromSeed(
      seedColor: Color(0xFFF2D3F2),
      surface: Color(0xFF383138),
      onSurface: Color(0xFF383138),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFFF2D3F2),
        fontSize: 22.0,
        letterSpacing: -0.75,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: Color(0xFFF2D3F2),
        letterSpacing: -0.50,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        color: Color(0xFFF2D3F2),
        letterSpacing: -0.50,
      ),
      bodySmall: TextStyle(
        fontSize: 12.0,
        color: Color(0xFFF2D3F2),
        letterSpacing: -0.50,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: TextStyle(
        color: Color(0xFFF2D3F2),
        fontSize: 12.0,
        fontFamily: "DepartureMono",
      ),
      decoration: BoxDecoration(color: Color(0xFF383138), borderRadius: .zero),
    ),
    fontFamily: 'DepartureMono',
    useMaterial3: true,
  );
}
