class Position {
  final int row;
  final int column;

  const Position({required this.row, required this.column});

  Map<String, dynamic> toJson() {
    return {'row': row, 'column': column};
  }

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(row: json['row'] as int, column: json['column'] as int);
  }

  @override
  bool operator ==(Object other) {
    return other is Position && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}
