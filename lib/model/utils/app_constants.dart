import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/services/auth_services.dart';

class AppConstants {
  static final _user = Get.find<AuthServices>().user.value;

  static const String searchKey = 'messages-search-key';
  static String profileImage(String ext) => '${FB.userImage}/${_user!.id}.$ext';
  static String postImage(String image, {required String time}) =>
      '${FB.post}/$time/$image';
}

class FB {
  static const String post = 'posts';
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
