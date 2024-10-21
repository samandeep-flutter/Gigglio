import 'package:flutter/material.dart';
import 'package:gigglio/model/utils/dimens.dart';

class BaseWidget extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;
  final Color? color;
  final Widget child;
  final bool? resizeBottom;
  final bool safeAreaBottom;

  const BaseWidget({
    super.key,
    this.appBar,
    this.padding,
    this.color,
    this.resizeBottom,
    this.safeAreaBottom = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeBottom,
      backgroundColor: color,
      body: SafeArea(
          bottom: safeAreaBottom,
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
