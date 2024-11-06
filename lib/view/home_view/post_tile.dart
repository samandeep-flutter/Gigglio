import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view/widgets/my_text_field_widget.dart';
import '../../model/models/post_model.dart';
import '../../model/utils/dimens.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controller.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/top_widgets.dart';

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
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: MyCachedImage.loading(
                    isAvatar: true,
                    // TODO: replace with loading widget for title and subtitle.
                  ),
                );
              }

              final json = snapshot.data?.data();
              final author = UserDetails.fromJson(json!);
              return ListTile(
                leading: MyCachedImage(
                  author.image,
                  isAvatar: true,
                ),
                title: Text(author.displayName),
                subtitle: Text(author.email),
              );
            }),
        _ImageCarousel(post: post),
        const SizedBox(height: Dimens.sizeSmall),
        StreamBuilder(
            stream: controller.posts.doc(id).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // TODO: replace with error widget for like icons.
                return const SizedBox();
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                // TODO: replace with loading widget for like icons.
                return const SizedBox();
              }
              final json = snapshot.data?.data();
              final post = PostModel.fromJson(json!);
              return Row(
                children: [
                  const SizedBox(width: Dimens.sizeSmall),
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
                  if (post.likes.isNotEmpty) Text(post.likes.length.toString()),
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
                  if (post.comments.isNotEmpty)
                    Text(post.comments.length.toString()),
                  const SizedBox(width: Dimens.sizeSmall),
                  IconButton(
                      onPressed: () => controller.sharePost(id),
                      style: IconButton.styleFrom(
                          padding: const EdgeInsets.only(bottom: 2)),
                      iconSize: bottomIcon,
                      icon: Icon(
                        Icons.ios_share_outlined,
                        color: scheme.disabled,
                      )),
                ],
              );
            }),
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

  void toComments(BuildContext context) {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          return BottomSheet(
              onClosing: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              animationController:
                  BottomSheet.createAnimationController(controller),
              builder: (context) {
                return MyBottomSheet(id, post);
              });
        });
  }
}

class _ImageCarousel extends StatefulWidget {
  final PostModel post;
  const _ImageCarousel({required this.post});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final pageContr = PageController();
  late PostModel post;
  int current = 0;

  @override
  void initState() {
    post = widget.post;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: context.height * .35),
          child: PageView.builder(
              controller: pageContr,
              onPageChanged: (value) => setState(() => current = value),
              itemCount: post.images.length,
              itemBuilder: (context, index) {
                return MyCachedImage(
                  width: context.width,
                  post.images[index],
                  fit: BoxFit.fitWidth,
                );
              }),
        ),
        if (post.images.length > 1) ...[
          const SizedBox(height: Dimens.sizeMedSmall),
          if (post.images.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(post.images.length, (index) {
                return PaginationDots(
                  current: current == index,
                  onTap: () {
                    pageContr.animateToPage(index,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut);
                  },
                );
              }),
            ),
        ],
      ],
    );
  }
}

class MyBottomSheet extends StatefulWidget {
  final String id;
  final PostModel post;
  const MyBottomSheet(this.id, this.post, {super.key});

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  List<UserDetails> users = [];
  HomeController controller = Get.find();

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  Future<void> _getUsers() async {
    controller.isCommentsLoading.value = true;
    List<UserDetails> details = [];
    final collection = await controller.users.get();

    for (var e in collection.docs) {
      details.add(UserDetails.fromJson(e.data()));
    }

    users = details;
    controller.isCommentsLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final now = DateTime.now();

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              StringRes.comments,
              style: TextStyle(fontWeight: FontWeight.w600),
            )
          ],
        ),
        const MyDivider(),
        const SizedBox(height: Dimens.sizeDefault),
        Expanded(
          child: FutureBuilder(
              future: controller.posts.doc(widget.id).get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.only(top: context.height * 0.3),
                    child: Text(StringRes.errorUnknown,
                        style: TextStyle(color: scheme.textColorLight)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    controller.isCommentsLoading.value) {
                  // TODO: replace with loading widget for comments.
                  return const SnapshotLoading();
                }

                final json = snapshot.data?.data();
                final post = PostModel.fromJson(json!);

                if (post.comments.isEmpty) {
                  return Container(
                    margin: EdgeInsets.only(top: context.height * 0.3),
                    child: Text(StringRes.noComments,
                        style: TextStyle(color: scheme.textColorLight)),
                  );
                }
                return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.sizeLarge),
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      final date = comment.dateTime.toDateTime;
                      final author = users.firstWhere((e) {
                        return e.id == comment.author;
                      });
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimens.sizeSmall),
                        child: Row(
                          children: [
                            MyCachedImage(
                              author.image,
                              isAvatar: true,
                              avatarRadius: 24,
                            ),
                            const SizedBox(width: Dimens.sizeDefault),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        author.displayName,
                                        style: const TextStyle(
                                            fontSize: Dimens.fontMed),
                                      ),
                                      const SizedBox(width: Dimens.sizeSmall),
                                      Text(
                                        Utils.timeFromNow(date, now),
                                        style: TextStyle(
                                            fontSize: Dimens.fontMed,
                                            color: scheme.disabled),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: Text(comment.title)),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    });
              }),
        ),
        SafeArea(
            minimum: EdgeInsets.only(
              bottom: context.mediaQuery.viewInsets.bottom + Dimens.sizeSmall,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    fieldKey: controller.commentKey,
                    maxLines: 1,
                    margin: const EdgeInsets.only(left: Dimens.sizeDefault),
                    title: 'add a comment...',
                    capitalization: TextCapitalization.sentences,
                    controller: controller.commentContr,
                  ),
                ),
                const SizedBox(width: Dimens.sizeDefault),
                IconButton.filled(
                  onPressed: () =>
                      controller.postComment(widget.id, post: widget.post),
                  icon: const Icon(Icons.send),
                ),
                const SizedBox(width: Dimens.sizeDefault)
              ],
            ))
      ],
    );
  }
}
