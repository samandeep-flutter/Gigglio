import 'package:get/get.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view/auth_view/forgot_password.dart';
import 'package:gigglio/view/auth_view/signin_screen.dart';
import 'package:gigglio/view/auth_view/signup_screen.dart';
import 'package:gigglio/view/auth_view/verify_email.dart';
import 'package:gigglio/view/home_view/goto_post.dart';
import 'package:gigglio/view/home_view/notification_screen.dart';
import 'package:gigglio/view/messages_view/chat_screen.dart';
import 'package:gigglio/view/messages_view/new_chat_screen.dart';
import 'package:gigglio/view/profile_view/add_friends.dart';
import 'package:gigglio/view/profile_view/change_password.dart';
import 'package:gigglio/view/profile_view/edit_profile.dart';
import 'package:gigglio/view/profile_view/goto_profile.dart';
import 'package:gigglio/view/profile_view/my_posts.dart';
import 'package:gigglio/view/profile_view/settings_screen.dart';
import 'package:gigglio/view/profile_view/view_requests.dart';
import 'package:gigglio/view/root_view.dart';
import 'package:gigglio/view/profile_view/privacy_policy.dart';
import 'package:gigglio/view_models/bindings/home_bindings.dart';
import 'package:gigglio/view_models/bindings/messages_bindings.dart';
import 'package:gigglio/view_models/bindings/profile_bindings.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import '../../view/home_view/add_post.dart';
import '../bindings/auth_bindings.dart';
import '../bindings/root_bindings.dart';

class AppPages {
  static final AuthServices _auth = Get.find();
  static String get initial => _auth.verify();

  static final List<GetPage> pages = [
    GetPage(
      name: Routes.signUp,
      page: () => const SignUpScreen(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: Routes.signIn,
      page: () => const SignInScreen(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: Routes.forgotPass,
      page: () => const ForgotPassword(),
    ),
    GetPage(
      name: Routes.verifyEmail,
      page: () => const VerifyEmail(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: Routes.rootView,
      page: () => const RootView(),
      binding: RootBindings(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: Routes.addPost,
      page: () => const AddPost(),
      transition: Transition.leftToRight,
      binding: HomeBindings(),
    ),
    GetPage(
      name: Routes.gotoPost,
      page: () => const GotoPost(),
    ),
    GetPage(
      name: Routes.chatScreen,
      page: () => const ChatScreen(),
      binding: MessagesBindings(),
    ),
    GetPage(
      name: Routes.newChat,
      page: () => const NewChatScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfile(),
      binding: ProfileBindings(),
    ),
    GetPage(
      name: Routes.gotoProfile,
      page: () => const GotoProfile(),
    ),
    GetPage(
      name: Routes.myPosts,
      page: () => const MyPosts(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: Routes.viewRequests,
      page: () => const ViewRequests(),
    ),
    GetPage(
      name: Routes.addFriends,
      page: () => const AddFriends(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
      binding: ProfileBindings(),
    ),
    GetPage(
      name: Routes.changePass,
      page: () => const ChangePassword(),
    ),
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const PrivacyPolicy(),
    ),
  ];
}
