import 'package:flutter/material.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../data/utils/dimens.dart';

class LoadingButton extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool enable;
  final Color? loaderColor;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? border;
  final EdgeInsets? margin;
  final double? width;
  final bool defWidth;
  final bool compact;
  final VoidCallback onPressed;
  const LoadingButton({
    super.key,
    this.padding,
    this.margin,
    this.width,
    this.enable = true,
    this.defWidth = false,
    this.compact = false,
    this.backgroundColor,
    this.foregroundColor,
    this.loaderColor,
    this.border,
    required this.isLoading,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      width: defWidth ? null : width ?? 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? scheme.primary,
            foregroundColor: foregroundColor ?? scheme.onPrimary,
            visualDensity: compact ? VisualDensity.compact : null,
            shape: border != null
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                    Radius.circular(border!),
                  ))
                : null,
            padding: padding ??
                const EdgeInsets.symmetric(vertical: Dimens.sizeDefault)),
        onPressed: enable && !isLoading ? onPressed : null,
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

class LoadingIcon extends StatelessWidget {
  final IconButtonStyle buttonStyle;
  final Widget icon;
  final bool loading;
  final double? loaderSize;
  final ButtonStyle? style;
  final VoidCallback onPressed;
  const LoadingIcon({
    super.key,
    required this.buttonStyle,
    required this.icon,
    required this.loading,
    required this.onPressed,
    this.loaderSize,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    switch (buttonStyle) {
      case IconButtonStyle.outlined:
        return IconButton.outlined(
          style: style ??
              IconButton.styleFrom(
                side: BorderSide(color: scheme.textColorLight, width: 2),
                padding: const EdgeInsets.all(Dimens.sizeMedSmall),
                foregroundColor: scheme.textColor,
              ),
          onPressed: onPressed,
          icon: loading
              ? SizedBox.square(
                  dimension: loaderSize ?? 24,
                  child: const CircularProgressIndicator())
              : icon,
        );
      case IconButtonStyle.filled:
        return IconButton.filled(
          style: style ??
              IconButton.styleFrom(
                side: BorderSide(color: scheme.textColorLight, width: 2),
                padding: const EdgeInsets.all(Dimens.sizeMedSmall),
                foregroundColor: scheme.textColor,
              ),
          onPressed: onPressed,
          icon: loading
              ? SizedBox.square(
                  dimension: loaderSize ?? 24,
                  child: const CircularProgressIndicator())
              : icon,
        );
    }
  }
}

enum IconButtonStyle { outlined, filled }
