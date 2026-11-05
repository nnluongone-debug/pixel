import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds and opens a pre-filled feedback email.
class FeedbackService {
  const FeedbackService();

  /// Public support address (also listed on the store page).
  static const supportEmail = 'nnluong.one@gmail.com';

  /// `mailto:` link with subject and a body ending in diagnostics. Encoded by
  /// hand: `Uri.queryParameters` turns spaces into `+`, which many mail apps
  /// show literally.
  static Uri buildMailUri({
    required String subject,
    required String hint,
    required String version,
    required String build,
    required String locale,
    String? os,
  }) {
    final osLine =
        os ??
        '${Platform.operatingSystem} '
            '${Platform.operatingSystemVersion}';
    final body =
        '$hint\r\n\r\n\r\n\r\n'
        '----\r\n'
        'App: $version ($build)\r\n'
        'OS: $osLine\r\n'
        'Locale: $locale';
    final query =
        'subject=${Uri.encodeComponent('[PixelHabit $version] $subject')}'
        '&body=${Uri.encodeComponent(body)}';
    return Uri.parse('mailto:$supportEmail?$query');
  }

  /// Opens the mail app; false when none can handle the link.
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Opening feedback email failed: $e');
      return false;
    }
  }
}
