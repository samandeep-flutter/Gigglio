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
  static const String post = 'Post';
  static const String editProfile = 'Edit Profile';
  static const String changePass = 'Change Password';
  static const String privacyPolicy = 'Privacy Policy';
  static const String notVerified = 'Not Verified';
  static const String logout = 'Logout';
  static const String cancel = 'Cancel';
  static const String settings = 'Settings';
  static const String messages = 'Messages';
  static const String newChat = 'New Chat';
  static const String addPost = 'Add Post';
  static const String refresh = 'Refresh';
  static const String newPost = 'New Post';
  static const String addPhotos = 'New Photos';
  static const String comments = 'Comments';
  static const String viewComments = 'View all comments';
  static const String noComments = 'Be the first one to comment..';
  static const String endofPosts = 'End of posts';
  static const String cancelled = 'Process cancelled';
  static const String confirmEmail = 'Confirm your Email';

  // errors
  static const String errorEmail = 'Invalid Email';
  static const String errorPhone = 'Invalid Phone Number';
  static const String errorMentionEmail = 'Please mention email first';
  static const String errorPassMatch = "Password dosen't match";
  static const String errorPassSame = 'Password is same as old';
  static const String errorWeakPass = 'The password provided is too weak';
  static const String errorCriteria = 'Password criteria dosen\'t match';
  static String errorEmpty(String title) => '$title is required';
  static const String errorSignCancel = 'Sign In cancelled';
  static const String errorUnknown = 'Something went wrong, try again';
  static const String errorSelect = 'Fill all required fields';
  static const String errorLoad = 'Failed to load data, refresh to load again';
  static const String errorCredentials = 'Something went wrong,'
      ' please login again';

  // long texts
  static const String signinDesc = 'Welcome back! Sign in to Gigglio and '
      'reconnect with your friends, share your moments, and keep the giggles going.';
  static const String singupDesc = 'Join Gigglio today! Create your profile,'
      ' connect with friends, and start sharing the fun.';
  static const String forgotPassDesc = 'No worries! Enter your email to '
      'reset your password and get back to the fun in no time.';
  static const String forgotPassOKDesc = 'We\'ve sent you an email with '
      'instructions to reset your password. Once reset, '
      'log in with your new credentials and get back to Gigglio.';
  static const String logoutDesc = 'Are you sure you want to log out?'
      ' We\'ll miss you! Come back soon..';
  static const String editProfileDesc = 'Want to update your look? Tap your'
      ' current profile photo to upload a new one.';
  static const String newPassDesc = 'Create a strong password with at least'
      ' 6 characters, including a mix of letters,'
      ' numbers, and symbols for better security.';
  static const String emailConfirmDesc = 'Please confirm your email'
      ' by clicking the link we sent to your inbox';
  static const String reauthDesc = 'For your security, please reauthenticate '
      'to continue. Confirm your identity by signing in again';
  static const String defBio = 'Hey there! I\'m on Gigglio. Let\'s '
      'chat and share some fun moments!';
  static const String noMessages = 'No conversations yet! Press +'
      ' to start a chat.';

  // box
  static const String boxName = 'gigglio';
  static const String boxToken = '$boxName:token';
  static const String keyTheme = '$boxName:theme';
  static const String keyUser = '$boxName:user';
}

showToast(String text, {int? timeInSec}) {
  Fluttertoast.showToast(msg: text, timeInSecForIosWeb: timeInSec ?? 1);
}
