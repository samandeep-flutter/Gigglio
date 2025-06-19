import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/comments_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/post_details_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/home_view/post_details.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/home_view/share_tile.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../data/data_models/post_model.dart';
import '../../data/utils/dimens.dart';
import '../widgets/image_carosual.dart';
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
              if (widget.post.author.id == bloc.box.uid!) return;
              context.pushNamed(AppRoutes.gotoProfile,
                  extra: widget.post.author.id);
            },
          ),
          title: Text(widget.post.author.displayName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: Dimens.fontExtraLarge,
              color: scheme.textColor),
          subtitle: Text(widget.post.author.bio ?? '',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitleTextStyle: TextStyle(color: scheme.textColorLight),
          trailing: IconButton(
              onPressed: _showMore, icon: const Icon(Icons.more_vert)),
        ),
        if (widget.post.images.isNotEmpty)
          ImageCarousel(images: widget.post.images),
        const SizedBox(height: Dimens.sizeSmall),
        DefaultTextStyle.merge(
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: Dimens.fontLarge),
          child: StreamBuilder(
              stream: bloc.posts.doc(widget.post.id).snapshots(),
              builder: (context, snapshot) {
                final json = snapshot.data?.data();
                PostDbModel? post;
                try {
                  post = PostDbModel.fromJson(json!);
                } catch (_) {}
                return Row(
                  children: [
                    const SizedBox(width: Dimens.sizeSmall),
                    IconButton(
                      onPressed: () {
                        if (post == null) return;
                        final id = widget.post.id!;
                        final contains = post.likes.contains(bloc.box.uid!);
                        bloc.add(RootPostLiked(id, contains: contains));
                      },
                      isSelected: post?.likes.contains(bloc.box.uid!) ?? false,
                      iconSize: Dimens.sizeMidLarge,
                      selectedIcon: const Icon(Icons.favorite),
                      icon: const Icon(Icons.favorite_outline),
                    ),
                    Builder(builder: (context) {
                      final length = post?.likes.length ?? 0;
                      return Text(length > 0 ? length.format : '\t');
                    }),
                    const SizedBox(width: Dimens.sizeSmall),
                    IconButton(
                      onPressed: _toComments,
                      style: IconButton.styleFrom(
                          padding: const EdgeInsets.only(top: 2)),
                      iconSize: Dimens.sizeMidLarge,
                      icon: const Icon(Icons.comment_outlined),
                    ),
                    Builder(builder: (context) {
                      final length = post?.comments.length ?? 0;
                      return Text(length > 0 ? length.format : '\t');
                    }),
                    const SizedBox(width: Dimens.sizeSmall),
                    IconButton(
                      onPressed: _sharePost,
                      style: IconButton.styleFrom(
                          padding: const EdgeInsets.only(bottom: 4)),
                      iconSize: Dimens.sizeMidLarge,
                      icon: const Icon(Icons.ios_share_outlined),
                    ),
                  ],
                );
              }),
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
          return BlocProvider(
            create: (_) => PostDetailsBloc(),
            child: PostDetails(widget.post, widget.reload),
          );
        });
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
        builder: (_) {
          return BlocProvider(
            create: (_) => CommentsBloc(),
            child: CommentSheet(widget.post.id!),
          );
        });
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
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                  children: [
                    TextSpan(
                      text: widget.author,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '\t\t'),
                    TextSpan(text: widget.text),
                  ]),
              const TextSpan(text: '\t\t\t\t'),
            ],
            isOverflowing: (overflowing) {
              showLess = overflowing;
              setState(() {});
            },
          ),
          if (showLess)
            GestureDetector(
              onTap: onTap,
              child: const Text(
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
