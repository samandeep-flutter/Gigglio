import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/auth_bloc/forgot_pass_bloc.dart';
import 'package:gigglio/business_logic/auth_bloc/signin_bloc.dart';
import 'package:gigglio/business_logic/auth_bloc/signup_bloc.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/presentation/auth_view/forgot_password.dart';
import 'package:gigglio/presentation/auth_view/signin_screen.dart';
import 'package:gigglio/presentation/auth_view/signup_screen.dart';
import 'package:gigglio/presentation/home_view/goto_post.dart';
import 'package:gigglio/presentation/home_view/notification_screen.dart';
import 'package:gigglio/presentation/messages_view/chat_screen.dart';
import 'package:gigglio/presentation/messages_view/new_chat_screen.dart';
import 'package:gigglio/presentation/profile_view/add_friends.dart';
import 'package:gigglio/presentation/profile_view/change_password.dart';
import 'package:gigglio/presentation/profile_view/edit_profile.dart';
import 'package:gigglio/presentation/profile_view/goto_profile.dart';
import 'package:gigglio/presentation/profile_view/all_user_posts.dart';
import 'package:gigglio/presentation/profile_view/settings_screen.dart';
import 'package:gigglio/presentation/profile_view/view_requests.dart';
import 'package:gigglio/presentation/root_view.dart';
import 'package:gigglio/presentation/profile_view/privacy_policy.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:go_router/go_router.dart';

sealed class AppPages {
  static final AuthServices _auth = getIt();

  static GoRouter routes = GoRouter(
      initialLocation: '/${_auth.initialRoute}',
      debugLogDiagnostics: kDebugMode,
      navigatorKey: _auth.navigationKey,
      routes: [
        GoRoute(
          name: AppRoutes.signUp,
          path: AppRoutePaths.signUp,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => SignUpBloc(),
              child: const SignUpScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.signIn,
          path: AppRoutePaths.signIn,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => SignInBloc(),
              child: const SignInScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.forgotPass,
          path: AppRoutePaths.forgotPass,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => ForgotPassBloc(),
              child: const ForgotPassword(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.rootView,
          path: AppRoutePaths.rootView,
          builder: (_, state) => const RootView(),
        ),
        GoRoute(
          name: AppRoutes.notifications,
          path: AppRoutePaths.notifications,
          builder: (_, state) => const NotificationScreen(),
        ),
        GoRoute(
          name: AppRoutes.gotoPost,
          path: AppRoutePaths.gotoPost,
          builder: (_, state) => const GotoPost(),
        ),
        GoRoute(
          name: AppRoutes.chatScreen,
          path: AppRoutePaths.chatScreen,
          builder: (_, state) => const ChatScreen(),
        ),
        GoRoute(
          name: AppRoutes.newChat,
          path: AppRoutePaths.newChat,
          builder: (_, state) => const NewChatScreen(),
          // transition: Transition.downToUp,
        ),
        GoRoute(
          name: AppRoutes.editProfile,
          path: AppRoutePaths.editProfile,
          builder: (_, state) => const EditProfile(),
        ),
        GoRoute(
          name: AppRoutes.gotoProfile,
          path: AppRoutePaths.gotoProfile,
          builder: (_, state) => const GotoProfile(),
        ),
        GoRoute(
          name: AppRoutes.allUserPosts,
          path: AppRoutePaths.allUserPosts,
          builder: (_, state) => const AllUserPosts(),
          // transition: Transition.zoom,
        ),
        GoRoute(
          name: AppRoutes.viewRequests,
          path: AppRoutePaths.viewRequests,
          builder: (_, state) => const ViewRequests(),
        ),
        GoRoute(
          name: AppRoutes.addFriends,
          path: AppRoutePaths.addFriends,
          builder: (_, state) => const AddFriends(),
        ),
        GoRoute(
          name: AppRoutes.settings,
          path: AppRoutePaths.settings,
          builder: (_, state) => const SettingsScreen(),
          // transition: Transition.rightToLeft,
        ),
        GoRoute(
          name: AppRoutes.changePass,
          path: AppRoutePaths.changePass,
          builder: (_, state) => const ChangePassword(),
        ),
        GoRoute(
          name: AppRoutes.privacyPolicy,
          path: AppRoutePaths.privacyPolicy,
          builder: (_, state) => const PrivacyPolicy(),
        ),
      ]);
}
