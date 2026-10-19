class Tile {
  final int id;

  int value;
  int row;
  int col;

  Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
  });

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      id: json['id'] as int,
      value: json['value'] as int,
      row: json['row'] as int,
      col: json['col'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'value': value, 'row': row, 'col': col};
  }

  Tile copy() {
    return Tile(id: id, value: value, row: row, col: col);
  }
}
