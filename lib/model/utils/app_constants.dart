import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppConstants {
  static const String appName = 'Gigglio';
  static const String fullAppName = 'Gigglio: Social App';
  static const String packageName = 'com.samtech.gigglio';
  static const String appUrl = 'https://gigglio.web.app';
  // box
  static const String boxName = 'gigglio';
  static const String keyTheme = '$boxName:theme';
  static const String keyUser = '$boxName:user';

  static const String messageSearchKey = 'messages-search-key';
  static const String usersSearchKey = 'users-search-key';
  static String profileImage(String image) => '${FB.userImage}/$image';
  static String share(String id) => '$appUrl/post/$id';
  static String postImage(String path) => '${FB.post}/$path';
}

class FB {
  static const String about = 'about';
  static const String post = 'posts';
  static const String messages = 'messages';
  static const String noti = 'notifications';
  static const String users = 'users';
  static const String userImage = '_userImages';
}

void logPrint(String? value, {Object? error}) {
  if (kReleaseMode) return;
  dev.log(value ?? 'null', error: error, name: 'log');
}

void dprint(String? value) {
  if (kReleaseMode) return;
  debugPrint(value ?? 'null');
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

showToast(String text, {int? timeInSec}) {
  Fluttertoast.showToast(msg: text, timeInSecForIosWeb: timeInSec ?? 1);
}
