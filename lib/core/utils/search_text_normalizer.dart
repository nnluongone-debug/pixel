/// Folds text for forgiving search: lowercase, Vietnamese diacritics
/// stripped in precomposed or decomposed form (`Uống nước` → `uong nuoc`), whitespace collapsed.
abstract final class SearchTextNormalizer {
  static const _groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static final Map<String, String> _fold = {
    for (final MapEntry(:key, :value) in _groups.entries)
      for (final char in value.split('')) char: key,
  };

  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      buffer.write(_fold[char] ?? char);
    }
    return buffer
        .toString()
        // Combining marks from decomposed (NFD) input.
        .replaceAll(RegExp('[\u0300-\u036f]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
