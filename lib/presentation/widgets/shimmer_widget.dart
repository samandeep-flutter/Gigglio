import 'package:flutter/material.dart';
import 'package:gigglio/data/utils/utils.dart';
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
          color: context.scheme.backgroundDark,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0))),
    );
  }
}

class ShimmerButton extends StatelessWidget {
  final double? borderRadius;
  final double? height;
  final double? width;

  const ShimmerButton({super.key, this.borderRadius, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: SizedBox(height: height, width: width, child: Shimmer.box),
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
    final shimmer = context.scheme.backgroundDark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimens.sizeSmall,
        horizontal: Dimens.sizeDefault,
      ),
      child: Row(children: [
        MyCachedImage.loading(
            isAvatar: true, avatarRadius: avatarRadius ?? Dimens.sizeLarge),
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
        trailing ?? Icon(Icons.more_vert, color: shimmer),
      ]),
    );
  }
}

class PostTileShimmer extends StatelessWidget {
  const PostTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final shimmer = context.scheme.backgroundDark;
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
            Icon(Icons.favorite, size: iconSize, color: shimmer),
            const SizedBox(width: Dimens.sizeMedium),
            Icon(Icons.comment, size: iconSize, color: shimmer),
            const SizedBox(width: Dimens.sizeMedium),
            Icon(Icons.ios_share_rounded, size: iconSize - 2, color: shimmer),
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

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: Dimens.sizeDefault),
      children: List.generate(3, (_) {
        return UserTileShimmer(
          title: context.width * .5,
          trailing: SizedBox.square(
            dimension: Dimens.sizeExtraLarge,
            child: Shimmer.box,
          ),
        );
      }),
    );
  }
}

class FriendsRequests extends StatelessWidget {
  const FriendsRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: Dimens.sizeLarge),
        itemBuilder: (context, _) {
          return UserTileShimmer(
            trailing: ShimmerButton(
              height: Dimens.sizeMidLarge,
              width: Dimens.sizeExtraLarge,
              borderRadius: Dimens.borderDefault,
            ),
          );
        });
  }
}

class MessagesShimmer extends StatelessWidget {
  const MessagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: Dimens.sizeDefault),
      children: List.generate(15, (_) {
        return UserTileShimmer(
          trailing: SizedBox(
            height: Dimens.sizeMedSmall,
            width: Dimens.sizeLarge,
            child: Shimmer.box,
          ),
        );
      }),
    );
  }
}

class CommentsShimmer extends StatelessWidget {
  const CommentsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return UserTileShimmer(
              trailing: const SizedBox(), subtitle: context.width * .7);
        });
  }
}

class ShareShimmer extends StatelessWidget {
  const ShareShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      padding: EdgeInsets.only(bottom: Dimens.sizeDefault),
      gridDelegate: Utils.gridDelegate(2, spacing: Dimens.sizeSmall),
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MyCachedImage.loading(
                isAvatar: true, avatarRadius: Dimens.sizeExtraLarge),
            const SizedBox(height: Dimens.sizeSmall),
            SizedBox(height: 10, width: 50, child: Shimmer.box)
          ],
        );
      },
    );
  }
}
