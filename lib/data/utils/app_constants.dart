import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppConstants {
  static const String appName = 'Gigglio';
  static const String fullAppName = 'Gigglio: Social App';
  static const String packageName = 'com.samtech.gigglio';
  static const String appUrl = 'https://gigglio.web.app';

  static const String messageSearchKey = 'messages-search-key';
  static const String usersSearchKey = 'users-search-key';
  static String profileImage(String image) => '${FB.userImage}/$image';
  static String share(String id) => '$appUrl/post/$id';
  static String postImage(String path) => '${FB.post}/$path';
  static String deletePost(String id) => '${FB.post}/$id';
}

class FB {
  static const String about = 'about';
  static const String post = 'posts';
  static const String messages = 'messages';
  static const String noti = 'notifications';
  static const String users = 'users';
  static const String userImage = 'userImages';
}

class BoxKeys {
  static const String boxName = 'gigglio';
  static const String theme = '$boxName:theme';
  static const String user = '$boxName:user';
}

void logPrint(Object? object, [String? name]) {
  if (kReleaseMode) return;
  final log = object is String? ? object : object.toString();
  dev.log(log ?? 'null', name: name ?? AppConstants.appName);
}

void dprint(Object? object) {
  if (kReleaseMode) return;
  final log = object is String? ? object : object.toString();
  debugPrint(log ?? 'null');
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
