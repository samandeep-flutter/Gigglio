import 'package:fluttertoast/fluttertoast.dart';

class StringRes {
  static const String appName = 'Gigglio';
  static const String fullAppName = 'Gigglio: Social App';
  static const String packageName = 'com.samtech.gigglio';

  static const String signin = 'Sign In';
  static const String signup = 'Sign Up';
  static const String forgotPass = 'Forgot Password';
  static const String continueWith = 'or continue with';
  static const String verifyAccount = 'Verify Account';
  static const String noAcc = 'Don\'t have an account?';
  static const String createAcc = 'Create Account';
  static const String accAlready = 'Already have an account?';
  static const String submit = 'Submit';
  static const String success = 'Success';
  static const String myPosts = 'My Posts';
  static const String editProfile = 'Edit Profile';
  static const String changePass = 'Change Password';
  static const String privacyPolicy = 'Privacy Policy';
  static const String notVerified = 'Not Verified';
  static const String logout = 'Logout';
  static const String cancel = 'Cancel';
  static const String settings = 'Settings';
  static const String messages = 'Messages';

  // errors
  static const String errorEmail = 'Invalid Email';
  static const String errorPhone = 'Invalid Phone Number';
  static const String errorMentionEmail = 'Please mention email first';
  static const String errorPassMatch = "Password dosen't match";
  static const String errorPassSame = 'Password is same as old';
  static const String errorWeakPass = 'The password provided is too weak';
  static String errorEmpty(String title) => '$title is required';
  static const String errorSignCancel = 'Sign In cancelled';
  static const String errorUnknown = 'Something went wrong, try again';
  static const String errorSelect = 'Fill all required fields';
  static const String errorCredentials = 'Something went wrong,'
      ' please login again';

  // long texts
  static const String signinDesc = 'Welcome back! Sign in to Gigglio and '
      'reconnect with your friends, share your moments, and keep the giggles going.';
  static const String singupDesc = 'Join Gigglio today! Create your profile,'
      ' connect with friends, and start sharing the fun.';
  static const String forgotPassDesc = 'No worries! Enter your email to '
      'reset your password and get back to the fun in no time.';
  static const String forgotPassOKText = 'We\'ve sent you an email with '
      'instructions to reset your password. Once reset, '
      'log in with your new credentials and get back to Gigglio.';
  static const String logoutText = 'Are you sure you want to log out?'
      ' We\'ll miss you! Come back soon..';

  // box
  static const String boxName = 'gigglio';
  static const String boxToken = '$boxName:token';
  static const String keyTheme = '$boxName:theme';
  static const String keyUser = '$boxName:user';
}

showToast(String text, {int? timeInSec}) {
  Fluttertoast.showToast(msg: text, timeInSecForIosWeb: timeInSec ?? 1);
}
