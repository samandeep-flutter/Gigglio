import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/home_view/share_tile.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../data/data_models/post_model.dart';
import '../../data/utils/app_constants.dart';
import '../../data/utils/color_resources.dart';
import '../../data/utils/dimens.dart';
import '../../business_logic/home_bloc/home_bloc.dart';
import '../widgets/image_carosual.dart';
import '../widgets/my_alert_dialog.dart';
import 'comments_screen.dart';

class PostTile extends StatefulWidget {
  final PostModel post;
  final VoidCallback reload;

  const PostTile(this.post, {super.key, required this.reload});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RootBloc>();
    final scheme = context.scheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: Dimens.sizeSmall),
          leading: MyAvatar(
            widget.post.author.image,
            isAvatar: true,
            onTap: () {
              if (widget.post.author.id == bloc.userId) return;
              context.pushNamed(AppRoutes.gotoProfile,
                  extra: widget.post.author.id);
            },
          ),
          title: Text(widget.post.author.displayName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(widget.post.author.email,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitleTextStyle: TextStyle(color: scheme.textColorLight),
          trailing: IconButton(
              onPressed: _showMore, icon: const Icon(Icons.more_vert)),
        ),
        if (widget.post.images.isNotEmpty)
          ImageCarousel(images: widget.post.images),
        const SizedBox(height: Dimens.sizeSmall),
        Row(
          children: [
            const SizedBox(width: Dimens.sizeSmall),
            StreamBuilder(
                stream: bloc.posts.doc(widget.post.id).snapshots(),
                builder: (context, snapshot) {
                  final json = snapshot.data?.data();
                  List<String>? likes;
                  try {
                    likes = PostDbModel.fromJson(json!).likes;
                  } catch (_) {}
                  return Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            if (likes == null) return;
                            if (likes.contains(bloc.userId)) {
                              bloc.posts.doc(widget.post.id).update({
                                'likes': FieldValue.arrayRemove([bloc.userId])
                              });
                            } else {
                              bloc.posts.doc(widget.post.id).update({
                                'likes': FieldValue.arrayUnion([bloc.userId])
                              });
                            }
                          },
                          isSelected: likes?.contains(bloc.userId) ?? false,
                          iconSize: Dimens.sizeMidLarge,
                          selectedIcon: const Icon(Icons.favorite),
                          icon: Icon(Icons.favorite_outline,
                              color: scheme.disabled)),
                      if (likes?.isNotEmpty ?? false)
                        Text(likes!.length.format),
                    ],
                  );
                }),
            const SizedBox(width: Dimens.sizeSmall),
            IconButton(
                onPressed: _toComments,
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.only(top: 2)),
                iconSize: Dimens.sizeMidLarge,
                icon: Icon(Icons.comment_outlined, color: scheme.disabled)),
            StreamBuilder(
                stream: bloc.posts.doc(widget.post.id).snapshots(),
                builder: (context, snapshot) {
                  final json = snapshot.data?.data();
                  if (json == null) return const SizedBox.shrink();
                  final length = PostDbModel.fromJson(json).comments.length;
                  return Text(length > 0 ? length.format : '\t');
                }),
            const SizedBox(width: Dimens.sizeSmall),
            IconButton(
                onPressed: _sharePost,
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.only(bottom: 4)),
                iconSize: Dimens.sizeMidLarge,
                icon: Icon(Icons.ios_share_outlined, color: scheme.disabled)),
          ],
        ),
        MoreText(widget.post.desc, author: widget.post.author.displayName),
        TextButton(
          onPressed: _toComments,
          style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              splashFactory: NoSplash.splashFactory,
              foregroundColor: scheme.textColorLight,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: const Text(StringRes.viewComments),
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.sizeDefault),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Utils.timeFromNow(widget.post.dateTime, 'ago'),
                  style: TextStyle(color: scheme.textColorLight),
                ),
              ],
            )),
        const SizedBox(height: Dimens.sizeLarge)
      ],
    );
  }

  void _showMore() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.scheme.background,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<HomeBloc>(),
          child: ShowMore(widget.post, widget.reload),
        );
      },
    );
  }

  void _sharePost() {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: context.scheme.background,
        builder: (_) => ShareTileSheet(widget.post.id!));
  }

  void _toComments() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: context.scheme.background,
      builder: (_) => CommentSheet(widget.post.id!),
    );
  }
}

class ShowMore extends StatefulWidget {
  final PostModel post;
  final VoidCallback reload;
  const ShowMore(this.post, this.reload, {super.key});

  @override
  State<ShowMore> createState() => _ShowMoreState();
}

class _ShowMoreState extends State<ShowMore> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();

    return MyBottomSheet(
      title: StringRes.actions,
      vsync: this,
      child: Padding(
        padding: Utils.paddingHoriz(Dimens.sizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.post.author.friends.contains(bloc.userId))
              CustomListTile(
                onTap: () {
                  context.pop();
                  // TODO: add friends unfriend logic
                  // bloc.add(HomeUserUnfriend(id: author.id));
                },
                leading: Icons.person_remove_outlined,
                title: StringRes.unFriend,
              )
            else
              CustomListTile(
                enable: !widget.post.author.requests.contains(bloc.userId),
                onTap: () {
                  context.pop();
                  // TODO: add friends request logic
                  // controller.sendReq(author.id);
                },
                leading: Icons.person_add_outlined,
                title: StringRes.sendFriendReq,
              ),
            if (bloc.userId == widget.post.author.id)
              CustomListTile(
                onTap: () async {
                  context.pop();
                  try {
                    for (final image in widget.post.images) {
                      final ref = bloc.storage.refFromURL(image);
                      await ref.delete();
                    }
                    await bloc.posts.doc(widget.post.id).delete();
                  } catch (e) {
                    logPrint(e, 'DELETE POST');
                  }
                  widget.reload();
                },
                title: StringRes.deletePost,
                iconColor: ColorRes.error,
                splashColor: ColorRes.onError,
                leading: Icons.delete_outline,
              ),
          ],
        ),
      ),
    );
  }
}

class MoreText extends StatefulWidget {
  final String? text;
  final String author;
  const MoreText(this.text, {super.key, required this.author});

  @override
  State<MoreText> createState() => _MoreTextState();
}

class _MoreTextState extends State<MoreText> {
  bool showLess = true;
  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    if (widget.text?.isEmpty ?? true) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: Dimens.sizeSmall),
      padding: const EdgeInsets.only(
          left: Dimens.sizeMedSmall, right: Dimens.sizeSmall),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyRichText(
            maxLines: showLess ? 2 : null,
            style: TextStyle(color: scheme.textColor),
            children: [
              TextSpan(
                  style: TextStyle(overflow: TextOverflow.ellipsis),
                  children: [
                    TextSpan(
                      text: widget.author,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '\t\t'),
                    TextSpan(text: widget.text),
                  ]),
              TextSpan(text: '\t\t\t\t'),
            ],
            isOverflowing: (overflowing) {
              showLess = overflowing;
              setState(() {});
            },
          ),
          if (showLess)
            GestureDetector(
              onTap: onTap,
              child: Text(
                '... show more',
                style: TextStyle(color: Colors.blue),
              ),
            )
        ],
      ),
    );
  }

  void onTap() {
    showLess = !showLess;
    setState(() {});
  }
}
