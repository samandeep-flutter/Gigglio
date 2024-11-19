import 'package:flutter/material.dart';
import 'package:gigglio/model/utils/color_resources.dart';

import '../../model/utils/dimens.dart';
import 'my_cached_image.dart';

class Shimmer {
  static get avatar => const _Shimmer(borderRadius: 50);
  static get box => const _Shimmer();
}

class _Shimmer extends StatelessWidget {
  final double? borderRadius;
  const _Shimmer({this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: ColorRes.shimmer,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0))),
    );
  }
}

class UserTileShimmer extends StatelessWidget {
  final double? avatarRadius;
  final double? title;
  final double? subtitle;
  final Widget? trailing;
  const UserTileShimmer({
    super.key,
    this.avatarRadius,
    this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimens.sizeSmall,
        horizontal: Dimens.sizeDefault,
      ),
      child: Row(children: [
        MyCachedImage.loading(isAvatar: true, avatarRadius: avatarRadius),
        const SizedBox(width: Dimens.sizeDefault),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: title ?? 100,
              height: 12,
              child: Shimmer.box,
            ),
            const SizedBox(height: Dimens.sizeSmall),
            SizedBox(
              width: subtitle ?? 150,
              height: 10,
              child: Shimmer.box,
            ),
          ],
        ),
        const Spacer(),
        trailing ?? const Icon(Icons.more_vert, color: ColorRes.shimmer),
      ]),
    );
  }
}
