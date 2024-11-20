import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/color_resources.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view/home_view/share_tile.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../model/models/post_model.dart';
import '../../model/utils/dimens.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controllers/home_controller.dart';
import '../widgets/image_carosual.dart';
import '../widgets/my_cached_image.dart';
import 'comments_screen.dart';

class PostTile extends GetView<HomeController> {
  final PostModel post;
  final bool last;
  final String id;

  const PostTile({
    super.key,
    required this.id,
    required this.post,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final user = controller.authServices.user.value;
    double bottomIcon = 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
            stream: controller.users.doc(post.author).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const ListTile(
                  leading: MyCachedImage.error(isAvatar: true),
                  subtitle: Text(StringRes.errorLoad),
                  trailing: Icon(Icons.more_vert),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const UserTileShimmer();
              }

              final json = snapshot.data?.data();
              final author = UserDetails.fromJson(json!);
              return ListTile(
                contentPadding: const EdgeInsets.only(left: Dimens.sizeDefault),
                leading: InkWell(
                  onTap: () => controller.gotoProfile(author.id),
                  splashColor: scheme.disabled.withOpacity(.7),
                  borderRadius: BorderRadius.circular(Dimens.sizeMidLarge),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: MyCachedImage(
                      author.image,
                      isAvatar: true,
                      avatarRadius: 20,
                    ),
                  ),
                ),
                title: Text(author.displayName),
                subtitle: Text(
                  author.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitleTextStyle: TextStyle(
                  color: scheme.textColorLight,
                  fontSize: Dimens.fontMed,
                ),
                trailing: IconButton(
                  onPressed: () => showMore(
                    context,
                    author: author,
                    doc: id,
                    dateTime: post.dateTime,
                  ),
                  icon: const Icon(Icons.more_vert),
                ),
              );
            }),
        ImageCarousel(images: post.images),
        const SizedBox(height: Dimens.sizeSmall),
        Row(
          children: [
            const SizedBox(width: Dimens.sizeSmall),
            StreamBuilder(
                stream: controller.posts.doc(id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.favorite_outline,
                        color: scheme.disabled,
                        size: bottomIcon,
                      ),
                    );
                  }

                  final json = snapshot.data?.data();
                  final post = PostModel.fromJson(json!);
                  return Row(
                    children: [
                      IconButton(
                          onPressed: () => controller.likePost(id, post: post),
                          style: IconButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 2)),
                          isSelected: post.likes.contains(user!.id),
                          iconSize: bottomIcon,
                          selectedIcon: const Icon(Icons.favorite),
                          icon: Icon(
                            Icons.favorite_outline,
                            color: scheme.disabled,
                          )),
                      if (post.likes.isNotEmpty)
                        Text(post.likes.length.toString()),
                    ],
                  );
                }),
            const SizedBox(width: Dimens.sizeSmall),
            IconButton(
                onPressed: () => toComments(context),
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.only(top: 2)),
                iconSize: bottomIcon,
                icon: Icon(
                  Icons.comment_outlined,
                  color: scheme.disabled,
                )),
            StreamBuilder(
                stream: controller.posts.doc(id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  final json = snapshot.data?.data();
                  final length = PostModel.fromJson(json!).comments.length;
                  return Text(length > 0 ? '$length' : '');
                }),
            const SizedBox(width: Dimens.sizeSmall),
            IconButton(
                onPressed: () => sharePost(context, doc: id),
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.only(bottom: 4)),
                iconSize: bottomIcon - 2,
                icon: Icon(
                  Icons.ios_share_outlined,
                  color: scheme.disabled,
                )),
          ],
        ),
        if (post.desc?.isNotEmpty ?? false)
          Container(
              margin: const EdgeInsets.only(
                top: Dimens.sizeSmall,
                left: Dimens.sizeMedSmall,
                right: Dimens.sizeSmall,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream: controller.users.doc(post.author).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return const SizedBox();
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          final json = snapshot.data?.data();
                          UserDetails user = UserDetails.fromJson(json!);
                          return RichText(
                              text: TextSpan(
                                  style: TextStyle(color: scheme.textColor),
                                  children: [
                                TextSpan(
                                  text: user.displayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const WidgetSpan(
                                    child: SizedBox(width: Dimens.sizeSmall)),
                                TextSpan(text: post.desc),
                                const WidgetSpan(
                                    child: SizedBox(width: Dimens.sizeDefault)),
                              ]));
                        }),
                  ),
                ],
              )),
        TextButton(
            onPressed: () => toComments(context),
            style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                splashFactory: NoSplash.splashFactory,
                foregroundColor: scheme.textColorLight,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text(StringRes.viewComments)),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.sizeDefault),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Utils.timeFromNow(post.dateTime.toDateTime, DateTime.now()),
                  style: TextStyle(color: scheme.textColorLight),
                ),
              ],
            )),
        if (last) ...[
          const SizedBox(height: Dimens.sizeDefault),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                StringRes.endofPosts,
                style: TextStyle(color: scheme.textColorLight),
              )
            ],
          ),
        ],
        const SizedBox(height: Dimens.sizeLarge)
      ],
    );
  }

  void sharePost(BuildContext context, {required String doc}) {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) {
          return MyBottomSheet(
            title: StringRes.share,
            vsync: controller,
            onClose: () {
              // controller.
            },
            child: ShareTileSheet(onTap: controller.sharePost),
          );
        });
  }

  void showMore(BuildContext context,
      {required UserDetails author,
      required String doc,
      required String dateTime}) {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) {
          return MyBottomSheet(
            title: StringRes.actions,
            vsync: controller,
            child: MoreActions(author: author, doc: doc, dateTime: dateTime),
          );
        });
  }

  void toComments(BuildContext context) {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (context) {
          return MyBottomSheet(
              title: StringRes.comments,
              vsync: controller,
              onClose: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: CommentSheet(id: id, post: post));
        });
  }
}

class MoreActions extends GetView<HomeController> {
  final UserDetails author;
  final String doc;
  final String dateTime;

  const MoreActions({
    super.key,
    required this.author,
    required this.doc,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthServices>().user.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.sizeLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!author.friends.contains(user!.id) && author.id != user.id)
            CustomListTile(
              onTap: () => controller.addFriend(author.id),
              leading: Icons.person_add_outlined,
              title: StringRes.sendFriendReq,
            ),
          if (author.id == user.id)
            CustomListTile(
              onTap: () => controller.deletePost(doc, dateTime: dateTime),
              title: StringRes.deletePost,
              iconColor: ColorRes.onErrorContainer,
              splashColor: ColorRes.errorContainer,
              leading: Icons.delete_outline,
            ),
          if (author.friends.contains(user.id))
            CustomListTile(
              onTap: () => controller.unfriend(author.id),
              leading: Icons.person_remove_outlined,
              title: StringRes.unFriend,
            )
        ],
      ),
    );
  }
}
