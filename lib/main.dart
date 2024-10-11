import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view_models/routes/app_pages.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const ThemeServices(child: MyApp()));
}

Future<void> initServices() async {
  try {
    await Hive.initFlutter();
    await Hive.openBox(StringRes.boxName);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Get.putAsync(() => AuthServices().init());
  } catch (e) {
    logPrint('init error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AuthServices>().theme;

    return GetMaterialApp(
      title: StringRes.appName,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
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
