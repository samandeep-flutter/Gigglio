class ImageRes {
  static String get google => _toIcons('google.png');
  static String get twitter => _toIcons('twitter.png');
  static String get userThumbnail => _toImages('user.png');
  static String get chatBackground => _toImages('chat-background.jpeg');

  static String _toIcons(String icon) => 'assets/icons/$icon';
  static String _toImages(String image) => 'assets/images/$image';
}

class AssetRes {
  static const String privacyPolicy = 'assets/privacy_policy.html';
}
