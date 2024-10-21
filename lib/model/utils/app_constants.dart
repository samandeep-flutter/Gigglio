import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const String searchKey = 'messages-search-key';
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
