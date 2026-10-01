enum Difficulty { beginner, intermediate, expert }

extension DifficultyConfig on Difficulty {
  int get rows => switch (this) {
    .beginner => 9,
    .intermediate => 16,
    .expert => 16,
  };

  int get columns => switch (this) {
    .beginner => 9,
    .intermediate => 16,
    .expert => 30,
  };

  int get mineCount => switch (this) {
    .beginner => 10,
    .intermediate => 40,
    .expert => 99,
  };
}
