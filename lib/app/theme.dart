import 'package:flutter/material.dart';

ThemeData createTheme() {
  return ThemeData(
    colorScheme: .fromSeed(
      seedColor: Color(0xFFD28097),
      surface: Color(0xFFECCEC3),
      onSurface: Color(0xFF2D1B1B),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFF2D1B1B),
        fontSize: 22.0,
        letterSpacing: -0.75,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: Color(0xFF2D1B1B),
        letterSpacing: -0.50,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        color: Color(0xFF2D1B1B),
        letterSpacing: -0.50,
      ),
      bodySmall: TextStyle(
        fontSize: 12.0,
        color: Color(0xFF2D1B1B),
        letterSpacing: -0.50,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: TextStyle(
        color: Color(0xFFECCEC3),
        fontSize: 12.0,
        fontFamily: "DepartureMono",
      ),
      decoration: BoxDecoration(color: Color(0xFF2D1B1B), borderRadius: .zero),
    ),
    fontFamily: 'DepartureMono',
    useMaterial3: true,
  );
}
