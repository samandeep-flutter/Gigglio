import 'package:get/get.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view/auth_view/forgot_password.dart';
import 'package:gigglio/view/auth_view/signin_screen.dart';
import 'package:gigglio/view/auth_view/signup_screen.dart';
import 'package:gigglio/view/root_tabs_view/home_screen.dart';
import 'package:gigglio/view/root_tabs_view/messages_screen.dart';
import 'package:gigglio/view/root_tabs_view/profile_screen.dart';
import 'package:gigglio/view/root_tabs_view/settings_screen.dart';
import 'package:gigglio/view/root_view.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import '../bindings/auth_bindings.dart';
import '../bindings/root_bindings.dart';

class AppPages {
  static final AuthServices _auth = Get.find();
  static String get initial => _auth.initRoutes();

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
      binding: AuthBindings(),
    ),
    GetPage(
      name: Routes.rootView,
      page: () => const RootView(),
      binding: RootBindings(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: RootBindings(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      binding: RootBindings(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: Routes.messages,
      page: () => const MessagesScreen(),
      binding: RootBindings(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      binding: RootBindings(),
    ),
  ];
}
