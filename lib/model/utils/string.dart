class StringRes {
  static const String appName = 'Social Things';

  static const String signin = 'Sign In';
  static const String signup = 'Sign Up';
  static const String noAcc = 'Don\'t have an account?';
  static const String createAcc = 'Create Account';
  static const String signinDesc =
      'Welcome back! Sign in to Gigglio and reconnect with your friends, '
      'share your moments, and keep the giggles going.';
  static const String accAlready = 'Already have an account?';
  static const String singupDesc =
      'Join Gigglio today! Create your profile, connect with friends, and start sharing the fun.';

  // errors
  static const String errorEmail = 'Invalid Email';
  static const String errorPhone = 'Invalid Phone Number';
  static const String errorMentionEmail = 'Please mention email first';
  static const String errorPassMatch = "Password dosen't match";
  static const String errorPassSame = 'Password is same as old';
  static String errorEmpty(String title) => '$title is required';
  static const String errorSignCancel = 'Sign In cancelled';
  static const String errorUnknown = 'Something went wrong, try again';
  static const String errorSelect = 'Fill all required fields';
  static const String errorCredentials =
      'Something went wrong, please login again';

  // box
  static const String boxName = 'social-things';
  static const String boxToken = '$boxName:token';
  static const String keyTheme = '$boxName:theme';
  static const String keyUser = '$boxName:user';
}
