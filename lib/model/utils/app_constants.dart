import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {}

void logPrint(String? value, {Object? error}) {
  if (kReleaseMode) return;
  dev.log(value ?? 'null', error: error, name: 'log');
}

void dprint(String? value) {
  if (kReleaseMode) return;
  debugPrint(value ?? 'null');
}

class MyColoredBox extends StatelessWidget {
  final Widget child;
  const MyColoredBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Colors.blue[200]!, child: child);
  }
}
