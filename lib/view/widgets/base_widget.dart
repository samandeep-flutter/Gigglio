import 'package:flutter/material.dart';
import 'package:gigglio/model/utils/dimens.dart';

class BaseWidget extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;
  final Color? color;
  final Widget child;

  const BaseWidget({
    super.key,
    this.appBar,
    this.padding,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: color,
      body: SafeArea(
          bottom: false,
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: Dimens.sizeLarge,
                ),
            child: child,
          )),
    );
  }
}
