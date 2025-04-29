import 'package:flutter/material.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';
import '../../config/routes/routes.dart';
import 'my_cached_image.dart';

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
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.borderDefault),
        onTap: onTap,
        child: CircleAvatar(
          radius: 3,
          backgroundColor:
              current ? scheme.primary : scheme.disabled.withAlpha(80),
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
    final scheme = context.scheme;
    return Container(
      margin: margin ?? EdgeInsets.only(top: context.height * .1),
      alignment: Alignment.topCenter,
      child: SizedBox.square(
        dimension: Dimens.sizeMidLarge,
        child: CircularProgressIndicator(color: scheme.primary),
      ),
    );
  }
}

class ToolTipWidget extends StatelessWidget {
  final EdgeInsets? margin;
  final Alignment? alignment;
  final String? title;
  const ToolTipWidget({super.key, this.margin, this.title, this.alignment});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
        margin: margin ?? EdgeInsets.only(top: context.height * .1),
        alignment: alignment ?? Alignment.topCenter,
        child: Text(
          title ?? StringRes.errorUnknown,
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.textColorLight),
        ));
  }
}

class MyAvatar extends StatelessWidget {
  final String? image;
  final bool? isAvatar;
  final EdgeInsets? padding;
  final double? avatarRadius;
  final double? borderRadius;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? id;
  final VoidCallback? onTap;

  const MyAvatar(
    this.image, {
    super.key,
    this.onTap,
    this.id,
    this.padding,
    this.avatarRadius,
    this.isAvatar,
    this.fit,
    this.borderRadius,
    this.height,
    this.width,
  }) : assert(id != null || onTap != null);

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return InkWell(
      onTap: onTap ?? () => context.pushNamed(AppRoutes.gotoProfile, extra: id),
      borderRadius:
          BorderRadius.circular(borderRadius ?? Dimens.sizeExtraLarge),
      splashColor: scheme.disabled.withAlpha(125),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(Dimens.sizeExtraSmall),
        child: MyCachedImage(
          image,
          isAvatar: isAvatar ?? false,
          height: height,
          width: width,
          fit: fit,
          avatarRadius: avatarRadius,
          borderRadius: borderRadius != null
              ? BorderRadius.circular(borderRadius!)
              : null,
        ),
      ),
    );
  }
}

class FriendsTile extends StatelessWidget {
  final String title;
  final int count;
  final bool enable;
  final VoidCallback? onTap;

  const FriendsTile({
    super.key,
    required this.title,
    required this.count,
    this.onTap,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    String num = _format(count);
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.borderSmall),
      onTap: enable ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: Dimens.fontExtraTripleLarge,
                  fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: Dimens.fontMed)),
          const SizedBox(height: Dimens.sizeExtraSmall),
        ],
      ),
    );
  }

  String _format(int count) {
    if (count > 999999) {
      String newCount = (count / 1000000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}M';
    }
    if (count > 999) {
      String newCount = (count / 1000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}K';
    }
    return count.toString();
  }
}

class MyRichText extends StatelessWidget {
  final int? maxLines;
  final TextStyle? style;
  final List<InlineSpan> children;
  const MyRichText({
    super.key,
    this.maxLines,
    this.style,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxLines,
      text: TextSpan(style: style, children: children),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final Color? foregroundColor;
  final IconData? leading;
  final Widget? trailing;
  final Color? splashColor;
  final EdgeInsets? margin;
  final bool enable;
  final Color? iconColor;
  final VoidCallback? onTap;
  const CustomListTile({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.foregroundColor,
    this.margin,
    this.enable = true,
    this.splashColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ListTile(
        onTap: enable ? onTap : null,
        visualDensity: VisualDensity.compact,
        splashColor: splashColor,
        textColor: foregroundColor,
        iconColor: iconColor ?? foregroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimens.sizeSmall,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.borderSmall)),
        title: Text(title,
            style: TextStyle(
              color: enable ? scheme.textColor : scheme.disabled,
            )),
        leading: Icon(leading,
            size: Dimens.sizeMedium,
            color: enable ? iconColor ?? foregroundColor : scheme.disabled),
        trailing: trailing,
      ),
    );
  }
}
