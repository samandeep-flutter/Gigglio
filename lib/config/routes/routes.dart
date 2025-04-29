sealed class AppRoutes {
  // auth routes
  static const String signUp = 'sign-up';
  static const String signIn = 'sign-in';
  static const String forgotPass = 'forgot-password';

  //  root routes
  static const String rootView = 'root-view';
  static const String settings = 'settings';

  //  home routes
  static const String home = 'home';
  static const String notifications = 'notifications';
  static const String allUserPosts = 'all-user-post';
  static const String gotoPost = 'goto-post';

  //  messages routes
  static const String messages = 'messages';
  static const String chatScreen = 'chat-screen';
  static const String newChat = 'new-chat';

  //  profile routes
  static const String profile = 'profile';
  static const String userProfile = 'user-posts';
  static const String viewRequests = 'view-requests';
  static const String addFriends = 'add-friends';
  static const String editProfile = 'edit-profile';
  static const String gotoProfile = 'goto-profile';
  static const String changePass = 'change-password';
  static const String privacyPolicy = 'privacy-policy';
}

sealed class AppRoutePaths {
  //  auth routes
  static const String signUp = '/${AppRoutes.signUp}';
  static const String signIn = '/${AppRoutes.signIn}';
  static const String forgotPass = '/${AppRoutes.forgotPass}';

  // root routes
  static const String rootView = '/${AppRoutes.rootView}';
  static const String settings = '/${AppRoutes.settings}';

  // home routes
  static const String notifications = '/${AppRoutes.notifications}';
  static const String allUserPosts = '/${AppRoutes.allUserPosts}';
  static const String gotoPost = '/${AppRoutes.gotoPost}';

  // messages routes
  static const String chatScreen = '/${AppRoutes.chatScreen}';
  static const String newChat = '/${AppRoutes.newChat}';

  // profile routes
  static const String userProfile = '/${AppRoutes.userProfile}';
  static const String viewRequests = '/${AppRoutes.viewRequests}';
  static const String addFriends = '/${AppRoutes.addFriends}';
  static const String editProfile = '/${AppRoutes.editProfile}';
  static const String gotoProfile = '/${AppRoutes.gotoProfile}';
  static const String changePass = '/${AppRoutes.changePass}';
  static const String privacyPolicy = '/${AppRoutes.privacyPolicy}';
}
