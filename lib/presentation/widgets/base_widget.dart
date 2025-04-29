import 'package:flutter/material.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/services/extension_services.dart';

class BaseWidget extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BoxDecoration? decoration;
  final Widget? child;
  final bool? resizeBottom;
  final bool safeAreaBottom;

  const BaseWidget({
    super.key,
    this.appBar,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.resizeBottom,
    this.safeAreaBottom = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeBottom,
      backgroundColor: color ?? scheme.background,
      body: Container(
        decoration: decoration,
        child: SafeArea(
            bottom: safeAreaBottom,
            child: Container(
              margin: margin,
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: Dimens.sizeLarge,
                  ),
              child: child,
            )),
      ),
    );
  }
}
