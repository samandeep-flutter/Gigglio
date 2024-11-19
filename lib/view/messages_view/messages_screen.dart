import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/messages_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/messages_controller/messages_controller.dart';
import '../../services/theme_services.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final bodyTextStyle = context.textTheme.bodyMedium;

    return BaseWidget(
        padding: EdgeInsets.zero,
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.messages),
          actions: [
            TextButton.icon(
              onPressed: controller.toNewChat,
              label: const Text(StringRes.newChat),
              icon: const Icon(Icons.add),
            )
          ],
          centerTitle: false,
          // bottom: PreferredSize(
          //     preferredSize: const Size.fromHeight(kToolbarHeight),
          //     child: SearchTextField(
          //       title: 'Search',
          //       focusNode: controller.searchFoucs,
          //       margin: const EdgeInsets.symmetric(
          //         horizontal: Dimens.sizeDefault,
          //       ),
          //       controller: controller.searchContr,
          //       onClear: controller.onClear,
          //     )),
        ),
        child: StreamBuilder(
            stream: controller.messages.orderBy('last_updated').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SizedBox();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                  children: List.generate(15, (_) {
                    return UserTileShimmer(
                      avatarRadius: 24,
                      trailing:
                          SizedBox(height: 10, width: 30, child: Shimmer.box),
                    );
                  }),
                );
              }

              final docs = snapshot.data!.docs.where((e) {
                return e.id.contains(controller.authServices.user.value!.id);
              }).toList();

              if (docs.isEmpty) {
                return ToolTipWidget(
                    margin: EdgeInsets.symmetric(
                      vertical: context.height * .08,
                      horizontal: context.width * .22,
                    ),
                    title: StringRes.noMessages);
              }

              return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                  itemBuilder: (context, index) {
                    final json = docs[index].data();
                    final chat = MessagesModel.fromJson(json);
                    Messages last = chat.messages.last;
                    final otherUser = chat.users.firstWhere((e) {
                      return e.id != controller.authServices.user.value!.id;
                    });

                    return StreamBuilder(
                        stream: controller.users.doc(otherUser.id).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const ToolTipWidget(
                                title: StringRes.somethingWrong);
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return UserTileShimmer(
                              avatarRadius: 24,
                              trailing: SizedBox(
                                  height: 10, width: 30, child: Shimmer.box),
                            );
                          }
                          if (chat.messages.isEmpty) return const SizedBox();
                          final json = snapshot.data?.data();
                          final user = UserDetails.fromJson(json!);

                          return ListTile(
                            onTap: () => controller.toChatScreen(user),
                            leading: MyCachedImage(
                              user.image,
                              isAvatar: true,
                              avatarRadius: 24,
                            ),
                            title: Text(user.displayName),
                            subtitle: Text(last.text),
                            subtitleTextStyle: bodyTextStyle?.copyWith(
                              color: scheme.textColorLight,
                            ),
                            trailing: Text(
                              Utils.timeFromNow(
                                  last.dateTime.toDateTime, DateTime.now()),
                              style: TextStyle(color: scheme.disabled),
                            ),
                          );
                        });
                  });
            }));
  }
}
