import 'package:flutter/material.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';

class LoadingButton extends StatelessWidget {
  final Widget child;
  final bool? isLoading;
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
    this.isLoading,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      margin: margin,
      width: defWidth ? null : width ?? 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? scheme.primary,
          foregroundColor: foregroundColor ?? scheme.onPrimary,
          visualDensity: compact ? VisualDensity.compact : null,
          padding: padding ?? const EdgeInsets.all(Dimens.sizeMedSmall),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(border ?? Dimens.borderDefault),
          ),
        ),
        onPressed: enable && !(isLoading ?? false) ? onPressed : null,
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontSize: Dimens.fontLarge,
            fontWeight: FontWeight.w600,
          ),
          child: Builder(
            builder: (context) {
              if (!(isLoading ?? false)) return child;
              return SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  color: loaderColor ?? scheme.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoadingIcon extends StatelessWidget {
  final Widget icon;
  final bool? loading;
  final bool? enable;
  final double? iconSize;
  final double? loaderSize;
  final Widget? selectedIcon;
  final bool? isSelected;
  final ButtonStyle? style;
  final bool _outlined;
  final Color? borderColor;
  final VoidCallback onPressed;
  const LoadingIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.enable,
    this.loading,
    this.iconSize,
    this.loaderSize,
    this.isSelected,
    this.selectedIcon,
    this.style,
  })  : _outlined = false,
        borderColor = null;
  const LoadingIcon.outlined({
    super.key,
    required this.icon,
    required this.onPressed,
    this.enable,
    this.loading,
    this.iconSize,
    this.loaderSize,
    this.isSelected,
    this.selectedIcon,
    this.borderColor,
    this.style,
  }) : _outlined = true;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return IconButton(
      style: style ??
          IconButton.styleFrom(
              foregroundColor: scheme.textColor,
              padding: const EdgeInsets.all(Dimens.sizeMedSmall),
              shape: _outlined
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimens.borderDefault),
                      side: BorderSide(
                          width: 2, color: borderColor ?? scheme.textColor),
                    )
                  : null),
      isSelected: isSelected,
      selectedIcon: selectedIcon,
      onPressed: (enable ?? true) && !(loading ?? false) ? onPressed : null,
      iconSize: iconSize,
      icon: Builder(
        builder: (context) {
          if (!(loading ?? false)) return icon;
          return Container(
            height: loaderSize,
            width: loaderSize,
            alignment: Alignment.center,
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(color: scheme.primary),
            ),
          );
        },
      ),
    );
  }
}

class LoadingTextButton extends StatelessWidget {
  final bool? enable;
  final Widget child;
  final bool? defWidth;
  final bool? compact;
  final VoidCallback onPressed;
  final bool? loading;
  final double? loaderSize;
  final Alignment? loaderAlignment;
  final double? width;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double? border;
  const LoadingTextButton({
    super.key,
    this.loading,
    this.width,
    this.enable,
    this.border,
    this.defWidth,
    this.compact,
    this.foregroundColor,
    this.backgroundColor,
    this.loaderAlignment,
    this.loaderSize,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return SizedBox(
      width: width ?? (defWidth ?? false ? null : 80),
      child: TextButton(
        onPressed: (enable ?? true) && !(loading ?? false) ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor ?? scheme.primary,
          visualDensity: compact ?? false ? VisualDensity.compact : null,
          padding: Utils.paddingHoriz(Dimens.sizeMedSmall),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(border ?? Dimens.borderSmall),
          ),
        ),
        child: Builder(
          builder: (context) {
            if (!(loading ?? false)) return child;
            return Align(
              alignment: loaderAlignment ?? Alignment.center,
              child: SizedBox.square(
                dimension: loaderSize ?? 24,
                child: CircularProgressIndicator(
                  color: foregroundColor ?? scheme.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
