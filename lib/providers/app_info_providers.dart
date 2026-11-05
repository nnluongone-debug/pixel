import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/feedback_service.dart';

/// Installed app version and build number.
final appInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

final feedbackServiceProvider = Provider<FeedbackService>(
  (ref) => const FeedbackService(),
);
