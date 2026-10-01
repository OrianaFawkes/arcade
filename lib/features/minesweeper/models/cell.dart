class Cell {
  final bool hasMine;
  final int adjacentMines;
  final bool isRevealed;
  final bool isFlagged;

  const Cell({
    this.hasMine = false,
    this.adjacentMines = 0,
    this.isRevealed = false,
    this.isFlagged = false,
  });

  Cell copyWith({
    bool? hasMine,
    int? adjacentMines,
    bool? isRevealed,
    bool? isFlagged,
  }) {
    return Cell(
      hasMine: hasMine ?? this.hasMine,
      adjacentMines: adjacentMines ?? this.adjacentMines,
      isRevealed: isRevealed ?? this.isRevealed,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasMine': hasMine,
      'adjacentMines': adjacentMines,
      'isRevealed': isRevealed,
      'isFlagged': isFlagged,
    };
  }

  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
      hasMine: json['hasMine'] as bool,
      adjacentMines: json['adjacentMines'] as int,
      isRevealed: json['isRevealed'] as bool,
      isFlagged: json['isFlagged'] as bool,
    );
  }
}
