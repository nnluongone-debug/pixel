/// 10 x 15 pixel picture spelling "LO" over "VE" for the demo matrix.
/// Rows run top to bottom; `#` is a letter pixel, `.` background.
abstract final class LovePattern {
  static const int columns = 10;
  static const int rows = 15;

  static const _glyphs = {
    'L': ['#...', '#...', '#...', '#...', '#...', '####'],
    'O': ['.##.', '#..#', '#..#', '#..#', '#..#', '.##.'],
    'V': ['#..#', '#..#', '#..#', '#..#', '.##.', '.##.'],
    'E': ['####', '#...', '###.', '#...', '#...', '####'],
  };

  /// Two 4x6 letters per line with a 1-column gap and margins.
  static final List<String> picture = () {
    String line(String a, String b, int i) =>
        '.${_glyphs[a]![i]}.${_glyphs[b]![i]}';
    const blank = '..........';
    return [
      blank,
      for (var i = 0; i < 6; i++) line('L', 'O', i),
      blank,
      for (var i = 0; i < 6; i++) line('V', 'E', i),
      blank,
    ];
  }();

  /// Whether stack slot [slot] (0 = bottom) of day [column] is a letter pixel.
  static bool isLetter(int column, int slot) =>
      picture[rows - 1 - slot][column] == '#';

  static int lettersInColumn(int column) => [
    for (var slot = 0; slot < rows; slot++)
      if (isLetter(column, slot)) slot,
  ].length;
}
