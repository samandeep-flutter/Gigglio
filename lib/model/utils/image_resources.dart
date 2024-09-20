class ImageRes {
  static String get google => _toIcons('google.png');
  static String get twitter => _toIcons('twitter.png');

  static String _toIcons(String icon) => 'assets/icons/$icon';
}
