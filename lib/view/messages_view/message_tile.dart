import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/messages_model.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/messages_controller/chat_controller.dart';

import '../../model/utils/dimens.dart';
import '../../services/theme_services.dart';

class MessageTile extends GetView<ChatController> {
  final Messages message;
  final bool isScrolled;

  const MessageTile({
    super.key,
    required this.message,
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.authServices.user.value;
    final scheme = ThemeServices.of(context);
    final time = message.dateTime.toDateTime;

    if (message.text.contains(AppConstants.appUrl)) {
      final doc = message.text.split('/').last;
      return Row(
        mainAxisAlignment: message.author == user!.id
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          const SizedBox(width: Dimens.sizeDefault),
          FutureBuilder(
              future: controller.posts.doc(doc).get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return MyCachedImage.loading(
                    borderRadius: BorderRadius.circular(Dimens.borderDefault),
                    height: 150,
                    width: 150,
                  );
                }
                final json = snapshot.data?.data();
                final post = PostModel.fromJson(json!);
                return Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimens.borderDefault),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: Dimens.sizeSmall),
                      FutureBuilder(
                          future: controller.users.doc(post.author).get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const ToolTipWidget(
                                margin: EdgeInsets.zero,
                                title: StringRes.somethingWrong,
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Row(children: [
                                const MyCachedImage.loading(
                                  isAvatar: true,
                                  avatarRadius: 16,
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 100,
                                  height: 20,
                                  child: Shimmer.box,
                                ),
                              ]);
                            }
                            final json = snapshot.data?.data();
                            final user = UserDetails.fromJson(json!);
                            return Row(
                              children: [
                                const SizedBox(width: Dimens.sizeSmall),
                                MyAvatar(
                                  user.image,
                                  isAvatar: true,
                                  id: user.id,
                                  avatarRadius: 14,
                                ),
                                const SizedBox(width: Dimens.sizeSmall),
                                Text(
                                  user.displayName,
                                  style: TextStyle(
                                      fontSize: Dimens.fontDefault,
                                      color: scheme.textColorLight),
                                ),
                                const SizedBox(width: Dimens.sizeSmall),
                              ],
                            );
                          }),
                      const SizedBox(height: Dimens.sizeExtraSmall),
                      MyAvatar(
                        onTap: () => controller.gotoPost(doc),
                        padding: EdgeInsets.zero,
                        post.images.first,
                        height: 200,
                        fit: BoxFit.fitWidth,
                      ),
                      Padding(
                          padding: const EdgeInsets.all(Dimens.sizeSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                post.desc ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimens.sizeExtraSmall),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    time.formatTime,
                                    style: TextStyle(
                                        color: scheme.textColorLight,
                                        fontSize: Dimens.fontMed),
                                  ),
                                  if (message.author == user.id) ...[
                                    const SizedBox(
                                        width: Dimens.sizeExtraSmall),
                                    Icon(
                                      Icons.check_rounded,
                                      color: isScrolled
                                          ? Colors.blue
                                          : scheme.disabled.withOpacity(.7),
                                      size: Dimens.sizeDefault,
                                    )
                                  ]
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                );
              }),
          const SizedBox(width: Dimens.sizeDefault),
        ],
      );
    }

    return Row(
      mainAxisAlignment: message.author == user!.id
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        const SizedBox(width: Dimens.sizeDefault),
        Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.sizeSmall),
          decoration: BoxDecoration(
              color: message.author == user.id
                  ? scheme.primaryContainer
                  : scheme.surface,
              borderRadius:
                  const BorderRadius.all(Radius.circular(Dimens.borderSmall))),
          padding: const EdgeInsets.all(Dimens.sizeSmall),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.text),
              Padding(
                  padding: const EdgeInsets.only(
                      left: Dimens.sizeSmall, top: Dimens.sizeSmall),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time.formatTime,
                        style: TextStyle(
                            color: scheme.textColorLight,
                            fontSize: Dimens.fontMed),
                      ),
                      if (message.author == user.id) ...[
                        const SizedBox(width: Dimens.sizeExtraSmall),
                        Icon(
                          Icons.check_rounded,
                          color: isScrolled
                              ? Colors.blue
                              : scheme.disabled.withOpacity(.7),
                          size: Dimens.sizeDefault,
                        )
                      ]
                    ],
                  )),
            ],
          ),
        ),
        const SizedBox(width: Dimens.sizeDefault),
      ],
    );
  }
}
