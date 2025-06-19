import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gigglio/business_logic/home_bloc/share_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/settings_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/user_profile_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:gigglio/services/notification_services.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:gigglio/config/routes/app_pages.dart';
import 'config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initServices();
  runApp(const ThemeServices(child: MyApp()));
}

Future<void> _initServices() async {
  dprint('initServices started...');
  try {
    await Firebase.initializeApp(options: DefaultFBOptions.currentPlatform);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light));
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    await GetStorage.init(BoxKeys.boxName);
    await dotenv.load();
    await getInit();
  } catch (e) {
    logPrint(e, 'init');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = BoxServices.instance.getTheme();

    return MaterialApp.router(
      title: StringRes.fullAppName,
      routerConfig: AppPages.routes,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveWrapper.builder(
        MultiBlocProvider(providers: [
          BlocProvider(create: (_) => RootBloc()),
          BlocProvider(create: (_) => UserProfileBloc()),
          BlocProvider(create: (_) => ShareBloc()),
          BlocProvider(create: (_) => SettingsBloc()),
        ], child: child ?? const SizedBox.shrink()),
        breakpoints: [
          const ResponsiveBreakpoint.resize(450, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(600, name: TABLET),
          const ResponsiveBreakpoint.resize(800, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(1700, name: '4K'),
        ],
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            primary: theme.primary,
            onPrimary: theme.onPrimary,
            seedColor: theme.primary,
            brightness: theme.brightness),
        useMaterial3: true,
        // fontFamily: StringRes.fontFamily,
        // textTheme: context.textTheme,
      ),
    );
  }
}
