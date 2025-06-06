import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gigglio/data/utils/string.dart';

class AppConstants {
  static const String packageName = 'com.samtech.gigglio';
  static const String appUrl = 'https://gigglio.web.app';

  static const String messageSearchKey = 'messages-search-key';
  static const String usersSearchKey = 'users-search-key';
  static String profileImage(String image) => 'user-images/$image';
  static String share(String id) => '$appUrl/posts/$id';
  static String postImage(String path) => 'posts/$path';
  static String deletePost(String id) => 'posts/$id';
}

class FBKeys {
  static const String about = 'about';
  static const String post = 'posts';
  static const String messages = 'messages';
  static const String noti = 'notifications';
  static const String users = 'users';
}

class BoxKeys {
  static const String boxName = 'gigglio';
  static const String theme = 'theme';
  static String chat(String id) => 'chat:$id';
}

void logPrint(Object? object, [String? name]) {
  if (kReleaseMode) return;
  final log = object is String? ? object : object.toString();
  dev.log(log ?? 'null', name: (name ?? StringRes.appName).toUpperCase());
}

void dprint(Object? object, {bool toString = true}) {
  if (kReleaseMode) return;
  final obj = toString ? object.toString() : object;
  final log = object is String? ? object : obj;
  // ignore: avoid_print
  print(log ?? 'null');
}

class MyColoredBox extends StatelessWidget {
  final Color? color;
  final Widget child;
  const MyColoredBox({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: color ?? Colors.black12, child: child);
  }
}

showToast(String text, {int? timeInSec}) async {
  await Fluttertoast.cancel();
  Future.delayed(const Duration(milliseconds: 300)).then((_) {
    Fluttertoast.showToast(
        msg: text,
        timeInSecForIosWeb: timeInSec ?? 1,
        gravity: ToastGravity.SNACKBAR);
  });
}
