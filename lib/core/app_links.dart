/// Public links to the app.
abstract final class AppLinks {
  static const androidPackage = 'com.nnluong.pixelquest';

  /// Play Store page tagged with an install referrer, so installs from
  /// shared images show up as `share / matrix` in Play Console acquisition.
  static const playStoreShareUrl =
      'https://play.google.com/store/apps/details?id=$androidPackage'
      '&referrer=utm_source%3Dshare%26utm_medium%3Dmatrix_image';
}
