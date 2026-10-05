import 'dart:convert';

import 'package:arcade/features/arcade/world/arcade_world_layout.dart';
import 'package:flutter/services.dart' show rootBundle;

class ArcadeWorldLoader {
  const ArcadeWorldLoader();

  Future<ArcadeWorldLayout> load(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);

    final json = jsonDecode(jsonString);

    if (json is! Map<String, dynamic>) {
      throw const FormatException('World file must contain a JSON object.');
    }

    return ArcadeWorldLayout.fromJson(json);
  }
}
