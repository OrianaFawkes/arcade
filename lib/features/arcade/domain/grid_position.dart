class GridPosition {
  final int x;
  final int y;

  const GridPosition(this.x, this.y);

  GridPosition copyWith({int? x, int? y}) {
    return GridPosition(x ?? this.x, y ?? this.y);
  }

  @override
  bool operator ==(Object other) {
    return other is GridPosition && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
