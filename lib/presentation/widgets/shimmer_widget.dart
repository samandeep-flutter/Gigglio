import 'package:flutter/material.dart';
import 'package:gigglio/data/utils/color_resources.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../data/utils/dimens.dart';
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

class PostTileShimmer extends StatelessWidget {
  const PostTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double iconSize = 35;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const UserTileShimmer(),
        SizedBox(
          height: context.height * .4,
          width: context.width,
          child: Shimmer.box,
        ),
        const SizedBox(height: Dimens.sizeDefault),
        Row(
          children: [
            const SizedBox(width: Dimens.sizeSmall),
            Icon(
              Icons.favorite,
              size: iconSize,
              color: ColorRes.shimmer,
            ),
            const SizedBox(width: Dimens.sizeMedium),
            Icon(
              Icons.comment,
              size: iconSize,
              color: ColorRes.shimmer,
            ),
            const SizedBox(width: Dimens.sizeMedium),
            Icon(
              Icons.ios_share_rounded,
              size: iconSize - 2,
              color: ColorRes.shimmer,
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(Dimens.sizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                  width: double.infinity,
                  child: Shimmer.box,
                ),
                const SizedBox(height: Dimens.sizeSmall),
                SizedBox(
                  height: 10,
                  width: 150,
                  child: Shimmer.box,
                ),
                const SizedBox(height: Dimens.sizeSmall),
                SizedBox(
                  height: 10,
                  width: 50,
                  child: Shimmer.box,
                ),
              ],
            )),
        const SizedBox(height: Dimens.sizeLarge)
      ],
    );
  }
}

class CountShimmer extends StatelessWidget {
  const CountShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (_) {
        return Expanded(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
                dimension: Dimens.sizeExtraLarge, child: Shimmer.box),
            const SizedBox(height: Dimens.sizeSmall),
            SizedBox(
                height: Dimens.sizeSmall,
                width: Dimens.sizeExtraDoubleLarge,
                child: Shimmer.box),
          ],
        ));
      }),
    );
  }
}
