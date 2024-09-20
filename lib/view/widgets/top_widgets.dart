import 'package:flutter/material.dart';
import '../../model/utils/dimens.dart';

class LoadingButton extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? loaderColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  const LoadingButton({
    super.key,
    this.style,
    this.padding,
    this.margin,
    this.loaderColor,
    required this.isLoading,
    required this.onPressed,
    required this.child,
  }) : assert(style == null || padding == null);

  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      child: ElevatedButton(
        style: style ??
            ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: padding ??
                    const EdgeInsets.symmetric(vertical: Dimens.sizeDefault)),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: loaderColor ?? scheme.onPrimary))
            : child,
      ),
    );
  }
}
