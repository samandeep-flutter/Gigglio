import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gigglio/config/firebase_options.dart';
import '../data/utils/app_constants.dart';

class MyNotifications {
  static final messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      await messaging.requestPermission();
      await messaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        logPrint(initialMessage.notification!.body, 'noti init');
      }
    } catch (e) {
      logPrint(e, 'fb init');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // TODO: show notification manually
      logPrint(message.toMap(), 'noti map');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logPrint(message.toMap(), 'noti onopen');
    });
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFBOptions.currentPlatform);
  } catch (e) {
    logPrint(e, 'noti');
  }
}
