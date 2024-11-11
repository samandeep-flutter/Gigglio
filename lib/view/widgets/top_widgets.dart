import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/theme_services.dart';
import '../../model/utils/dimens.dart';

class LoadingButton extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? loaderColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  const LoadingButton({
    super.key,
    this.style,
    this.padding,
    this.margin,
    this.width,
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
      width: width ?? 200,
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
    final scheme = ThemeServices.of(context);

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

class MyAlertDialog extends StatelessWidget {
  final String title;
  final TextStyle? titleTextStyle;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsets? actionPadding;
  final VoidCallback? onTap;

  const MyAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.onTap,
    this.actionPadding,
    this.titleTextStyle,
  }) : assert(
            (actions != null || onTap != null) &&
                !(actions != null && onTap != null),
            'Provide either custom actions or provide onTap');
  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return AlertDialog(
      backgroundColor: scheme.surface,
      title: Text(title),
      titleTextStyle: titleTextStyle,
      content: content,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.borderDefault)),
      buttonPadding: const EdgeInsets.only(right: Dimens.sizeDefault),
      actionsPadding: actionPadding,
      actions: actions ??
          [
            TextButton(
                onPressed: Get.back, child: const Text(StringRes.cancel)),
            TextButton(onPressed: onTap, child: const Text(StringRes.submit)),
          ],
    );
  }
}

class MyDivider extends StatelessWidget {
  final double? width;
  final double? thickness;
  final double? margin;
  const MyDivider({super.key, this.width, this.thickness, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: margin ?? 0),
        width: width,
        child: Divider(
          color: Colors.grey[300],
          thickness: thickness,
        ));
  }
}

class PaginationDots extends StatelessWidget {
  final bool current;
  final VoidCallback? onTap;
  const PaginationDots({super.key, required this.current, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.borderDefault),
        onTap: onTap,
        child: CircleAvatar(
          radius: 4,
          backgroundColor:
              current ? scheme.primary : scheme.disabled.withOpacity(.3),
        ),
      ),
    );
  }
}

class SnapshotLoading extends StatelessWidget {
  final EdgeInsets? margin;
  const SnapshotLoading({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return Container(
      margin: margin ?? EdgeInsets.only(top: context.height * .1),
      alignment: Alignment.topCenter,
      child: SizedBox.square(
        dimension: 30,
        child: CircularProgressIndicator(color: scheme.primary),
      ),
    );
  }
}

class ToolTipWidget extends StatelessWidget {
  final EdgeInsets? margin;
  final String? title;
  const ToolTipWidget({super.key, this.margin, this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return Container(
        margin: margin ?? EdgeInsets.only(top: context.height * .1),
        alignment: Alignment.topCenter,
        child: Text(
          title ?? StringRes.errorUnknown,
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.textColorLight),
        ));
  }
}
