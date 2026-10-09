import 'package:arcade/features/arcade/world/grid_position.dart';


class ArcadeStation {
  final String id;
  final String label;

  final GridPosition position;
  
  final String routeName;

  const ArcadeStation({
    required this.id,
    required this.label,
    required this.position,
    required this.routeName,
  });

  factory ArcadeStation.fromJson(Map<String, dynamic> json) {
    return ArcadeStation(
      id: json['id'] as String,
      label: json['label'] as String,
      position: GridPosition(
        json['x'] as int,
        json['y'] as int,
      ),
      routeName: json['routeName'] as String,
    );
  }
}