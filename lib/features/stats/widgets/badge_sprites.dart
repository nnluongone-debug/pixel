import '../../../domain/analytics/pixel_badge.dart';

/// 12x12 pixel-art sprites for badge artwork. One character per pixel:
/// `+` highlight, `#` base color, `o` shade, `.` transparent.
abstract final class BadgeSprites {
  static const int size = 12;

  static List<String> of(BadgeGlyph glyph) => switch (glyph) {
    BadgeGlyph.block => _block,
    BadgeGlyph.stack => _stack,
    BadgeGlyph.tower => _tower,
    BadgeGlyph.shield => _shield,
    BadgeGlyph.line => _line,
    BadgeGlyph.crown => _crown,
    BadgeGlyph.sun => _sun,
    BadgeGlyph.calendar => _calendar,
    BadgeGlyph.star => _star,
    BadgeGlyph.bolt => _bolt,
  };

  /// A single beveled brick.
  static const _block = [
    '............',
    '............',
    '............',
    '...++++++o..',
    '...+#####o..',
    '...+##+##o..',
    '...+#####o..',
    '...+#####o..',
    '...ooooooo..',
    '............',
    '............',
    '............',
  ];

  /// A 1-2-3 pyramid of bricks.
  static const _stack = [
    '............',
    '............',
    '............',
    '....+++o....',
    '....###o....',
    '..+++o+++o..',
    '..###o###o..',
    '+++o+++o+++o',
    '###o###o###o',
    '............',
    '............',
    '............',
  ];

  /// A castle keep with battlements.
  static const _tower = [
    '............',
    '.+o..+o..+o.',
    '.##..##..##.',
    '.##########.',
    '.##oo##oo##.',
    '.##########.',
    '.####++####.',
    '.###+##o###.',
    '.###+##o###.',
    '.###+##o###.',
    '.oooooooooo.',
    '............',
  ];

  /// A shield with a bright cross.
  static const _shield = [
    '............',
    '..++++++++..',
    '..+######o..',
    '..+##++##o..',
    '..+++++++o..',
    '..+##++##o..',
    '..+######o..',
    '...+####o...',
    '....+##o....',
    '.....oo.....',
    '............',
    '............',
  ];

  /// A cleared row with sparks flying off it.
  static const _line = [
    '............',
    '............',
    '...+....+...',
    '....+..+....',
    '............',
    '++++++++++++',
    '############',
    'oooooooooooo',
    '............',
    '....+..+....',
    '...+....+...',
    '............',
  ];

  /// A jewelled crown.
  static const _crown = [
    '............',
    '............',
    '.+...++...+.',
    '.#+..##..+#.',
    '.##+.##.+##.',
    '.####++####.',
    '.##########.',
    '.#++#++#++#.',
    '.##########.',
    '.oooooooooo.',
    '............',
    '............',
  ];

  /// A sun with rays.
  static const _sun = [
    '............',
    '.....+o.....',
    '.+o......+o.',
    '....++++....',
    '...+####o...',
    '+o.+####o.+o',
    '...+####o...',
    '....oooo....',
    '.+o......+o.',
    '.....+o.....',
    '............',
    '............',
  ];

  /// A calendar page with a check mark.
  static const _calendar = [
    '............',
    '..+o....+o..',
    '.++++++++++.',
    '.##########.',
    '.#oooooooo#.',
    '.#ooooooo+#.',
    '.#oooooo+o#.',
    '.#o+ooo+oo#.',
    '.#oo+o+ooo#.',
    '.#ooo+oooo#.',
    '.##########.',
    '............',
  ];

  /// A five-point star.
  static const _star = [
    '............',
    '.....++.....',
    '.....##.....',
    '....+##o....',
    '.++++##oooo.',
    '..+######o..',
    '...+####o...',
    '...+#oo#o...',
    '..+#o..o#o..',
    '..+o....oo..',
    '............',
    '............',
  ];

  /// A lightning bolt.
  static const _bolt = [
    '............',
    '......+++o..',
    '.....+##o...',
    '....+##o....',
    '...+##o.....',
    '..+#######o.',
    '.......##o..',
    '......##o...',
    '.....##o....',
    '....#o......',
    '...o........',
    '............',
  ];
}
