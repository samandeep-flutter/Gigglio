import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import '../../model/models/post_model.dart';
import '../../model/models/user_details.dart';
import '../../model/utils/dimens.dart';
import '../../model/utils/string.dart';
import '../../model/utils/utils.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controller.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/my_text_field_widget.dart';
import '../widgets/top_widgets.dart';

class CommentSheet extends StatefulWidget {
  final String id;
  final PostModel post;
  const CommentSheet(this.id, this.post, {super.key});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  List<UserDetails> users = [];
  RxBool isCommentsLoading = RxBool(false);
  HomeController controller = Get.find();

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  Future<void> _getUsers() async {
    isCommentsLoading.value = true;
    List<UserDetails> details = [];
    final collection = await controller.users.get();

    for (var e in collection.docs) {
      details.add(UserDetails.fromJson(e.data()));
    }

    users = details;
    isCommentsLoading.value = false;
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
                    padding: EdgeInsets.only(top: context.height * 0.1),
                    child: Text(StringRes.errorUnknown,
                        style: TextStyle(color: scheme.textColorLight)),
                  );
                }

                return Obx(() {
                  if (isCommentsLoading.value ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                        children: List.generate(3, (_) {
                      return UserTileShimmer(
                        trailing: const SizedBox(),
                        subtitle: context.width * .7,
                      );
                    }));
                  }

                  final json = snapshot.data?.data();
                  final post = PostModel.fromJson(json!);

                  if (post.comments.isEmpty) {
                    return Container(
                      margin: EdgeInsets.only(top: context.height * 0.1),
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
                    onPressed: () => controller.postComment(
                          widget.id,
                          postAuthor: users.firstWhere((e) {
                            return e.id == widget.post.author;
                          }),
                        ),
                    icon: const Icon(Icons.send)),
                const SizedBox(width: Dimens.sizeDefault)
              ],
            ))
      ],
    );
  }
}
