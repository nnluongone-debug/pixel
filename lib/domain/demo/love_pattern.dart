/// Pixel picture spelling "LO" over "VE" (4x4 letters) for the demo matrix.
/// Rows run top to bottom; `#` is a letter pixel, `.` background. Bricks
/// stack from the bottom, so each column is filled only up to its highest
/// letter pixel — above that the matrix stays empty.
abstract final class LovePattern {
  static const int columns = 10;

  static const _glyphs = {
    'L': ['#...', '#...', '#...', '####'],
    'O': ['####', '#..#', '#..#', '####'],
    'V': ['#..#', '#..#', '#..#', '.##.'],
    'E': ['####', '###.', '#...', '####'],
  };

  /// Two lines of two letters, 1-column margin and gap, 1-row gap.
  static final List<String> picture = () {
    String line(String a, String b, int i) =>
        '.${_glyphs[a]![i]}.${_glyphs[b]![i]}';
    return [
      for (var i = 0; i < 4; i++) line('L', 'O', i),
      '..........',
      for (var i = 0; i < 4; i++) line('V', 'E', i),
    ];
  }();

  static int get rows => picture.length;

  /// Whether stack slot [slot] (0 = bottom) of day [column] is a letter pixel.
  static bool isLetter(int column, int slot) =>
      slot < rows && picture[rows - 1 - slot][column] == '#';

  /// Bricks needed in [column]: up to and including its highest letter.
  static int heightOf(int column) {
    for (var slot = rows - 1; slot >= 0; slot--) {
      if (isLetter(column, slot)) return slot + 1;
    }
    return 0;
  }

  static int lettersInColumn(int column) => [
    for (var slot = 0; slot < heightOf(column); slot++)
      if (isLetter(column, slot)) slot,
  ].length;

  /// Habits needed: enough pink ones for the busiest column and enough dark
  /// filler ones for the column with the most gaps under its letters.
  static int get letterHabits => [
    for (var c = 0; c < columns; c++) lettersInColumn(c),
  ].reduce((a, b) => a > b ? a : b);

  static int get fillerHabits => [
    for (var c = 0; c < columns; c++) heightOf(c) - lettersInColumn(c),
  ].reduce((a, b) => a > b ? a : b);
}
