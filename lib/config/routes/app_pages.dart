import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/auth_bloc/forgot_pass_bloc.dart';
import 'package:gigglio/business_logic/auth_bloc/signin_bloc.dart';
import 'package:gigglio/business_logic/auth_bloc/signup_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/goto_post_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/new_post_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/notification_bloc.dart';
import 'package:gigglio/business_logic/messages_bloc/chat_bloc.dart';
import 'package:gigglio/business_logic/messages_bloc/new_chat_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/add_friends_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/edit_profile_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/settings_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/view_requests_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/presentation/home_view/new_post.dart';
import 'package:gigglio/presentation/profile_view/user_posts.dart';
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
          builder: (_, state) {
            return BlocProvider(
                create: (_) => NotificationBloc(),
                child: const NotificationScreen());
          },
        ),
        GoRoute(
          name: AppRoutes.newPost,
          path: AppRoutePaths.newPost,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => NewPostBloc(),
              child: const NewPost(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.gotoPost,
          path: AppRoutePaths.gotoPost,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => GotoPostBloc(),
              child: GotoPost(state.extra as String),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.chatScreen,
          path: AppRoutePaths.chatScreen,
          builder: (_, state) {
            final user = state.extra as UserDetails;
            final id = state.uri.queryParameters['id'];
            return BlocProvider(
              create: (_) => ChatBloc(),
              child: ChatScreen(id, user: user),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.newChat,
          path: AppRoutePaths.newChat,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => NewChatBloc(),
              child: const NewChatScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.editProfile,
          path: AppRoutePaths.editProfile,
          builder: (context, state) {
            return BlocBuilder<RootBloc, RootState>(
              bloc: context.read<RootBloc>(),
              buildWhen: (_, __) => false,
              builder: (context, state) {
                return BlocProvider(
                  create: (_) => EditProfileBloc(),
                  child: EditProfile(profile: state.profile!),
                );
              },
            );
          },
        ),
        GoRoute(
          name: AppRoutes.gotoProfile,
          path: AppRoutePaths.gotoProfile,
          builder: (_, state) {
            final id = state.extra as String;
            return GotoProfile(userId: id);
          },
        ),
        GoRoute(
          name: AppRoutes.userPosts,
          path: AppRoutePaths.userPosts,
          builder: (_, state) {
            final index = state.extra as int;
            return UserPosts(index);
          },
        ),
        GoRoute(
          name: AppRoutes.viewRequests,
          path: AppRoutePaths.viewRequests,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => ViewRequestsBloc(),
              child: const ViewRequests(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.addFriends,
          path: AppRoutePaths.addFriends,
          builder: (_, state) {
            return BlocProvider(
              create: (_) => AddFriendsBloc(),
              child: const AddFriends(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.settings,
          path: AppRoutePaths.settings,
          builder: (_, state) => const SettingsScreen(),
        ),
        GoRoute(
          name: AppRoutes.changePass,
          path: AppRoutePaths.changePass,
          builder: (context, state) {
            return BlocProvider(
              create: (_) => SettingsBloc(),
              child: const ChangePassword(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.privacyPolicy,
          path: AppRoutePaths.privacyPolicy,
          builder: (_, state) => const PrivacyPolicy(),
        ),
      ]);
}
