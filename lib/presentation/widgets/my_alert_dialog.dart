import 'package:flutter/material.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/extension_services.dart';
import 'top_widgets.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final TextStyle? titleTextStyle;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsets? actionPadding;
  final EdgeInsets? insetsPadding;
  final VoidCallback? onTap;

  const MyAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.onTap,
    this.insetsPadding,
    this.actionPadding,
    this.titleTextStyle,
  }) : assert(
          (actions != null || onTap != null) &&
              !(actions != null && onTap != null),
          'Provide either custom actions or provide onTap',
        );
  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return AlertDialog(
      backgroundColor: scheme.surface,
      title: Text(title),
      titleTextStyle: titleTextStyle,
      content: content,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.borderDefault),
      ),
      buttonPadding: const EdgeInsets.only(right: Dimens.sizeDefault),
      insetPadding: insetsPadding,
      actionsPadding: actionPadding,
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(StringRes.cancel),
            ),
            TextButton(onPressed: onTap, child: const Text(StringRes.submit)),
          ],
    );
  }
}

class MyBottomSheet extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final double? bottomPadding;
  final TickerProvider vsync;
  final VoidCallback? onClose;
  final Widget child;

  const MyBottomSheet({
    super.key,
    required this.title,
    required this.vsync,
    this.onClose,
    this.bottomPadding,
    this.isExpanded = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      backgroundColor: context.scheme.background,
      animationController: BottomSheet.createAnimationController(vsync),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onClose?.call();
                      },
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact),
                      child: const Text(
                        StringRes.close,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: Dimens.sizeDefault),
                  ],
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: Dimens.fontExtraLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.sizeSmall),
            const MyDivider(),
            const SizedBox(height: Dimens.sizeDefault),
            if (isExpanded) Expanded(child: child) else child,
            SafeArea(child: SizedBox(height: bottomPadding)),
          ],
        );
      },
    );
  }
}
