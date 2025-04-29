import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/theme_services.dart';
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
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await GetStorage.init(AppConstants.boxName);
    await getInit();
  } catch (e) {
    logPrint(e, 'init');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = getIt<AuthServices>().theme;

    return MaterialApp.router(
      title: AppConstants.appName,
      routerConfig: AppPages.routes,
      builder: (context, child) => ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(context, child!),
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
          useMaterial3: true),
    );
  }
}
