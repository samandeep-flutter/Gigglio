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
import 'package:gigglio/view/widgets/my_text_field_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/messages_controller/messages_controller.dart';
import '../../services/theme_services.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final user = controller.authServices.user.value;
    final bodyTextStyle = context.textTheme.bodyMedium;

    return BaseWidget(
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
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: SearchTextField(
                title: 'Search',
                focusNode: controller.searchFoucs,
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimens.sizeDefault,
                ),
                controller: controller.searchContr,
                onClear: controller.onClear,
              )),
        ),
        child: StreamBuilder(
            stream: controller.messages.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SizedBox();

              if (snapshot.connectionState == ConnectionState.waiting) {
                // TODO: replace with loading widget for messages.
                return const SnapshotLoading();
              }

              final docs = snapshot.data!.docs.where((e) {
                return e.id.contains(user!.id);
              }).toList();

              return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final users = docs[index].id.split(':');
                    final json = docs[index].data();
                    final list = List<Messages>.from(
                        json.entries.map((e) => Messages.fromJson(e.value)));
                    final chat = MessagesModel(users: users, messages: list);
                    final otherUser =
                        chat.users.firstWhere((e) => e != user!.id);
                    return StreamBuilder(
                        stream: controller.users.doc(otherUser).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            // TODO: replace with error widget for messages.
                            return const SnapshotError();
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // TODO: replace with loading widget for messages.
                            return const SnapshotLoading();
                          }
                          final json = snapshot.data?.data();
                          final user = UserDetails.fromJson(json!);

                          Messages? last;
                          if (chat.messages.isNotEmpty) {
                            last = chat.messages.last;
                          }
                          return ListTile(
                            leading: MyCachedImage(
                              user.image,
                              isAvatar: true,
                              avatarRadius: 24,
                            ),
                            title: Text(user.displayName),
                            subtitle: Text(last?.message ?? ''),
                            subtitleTextStyle: bodyTextStyle?.copyWith(
                              color: scheme.textColorLight,
                            ),
                            trailing: Text(
                              Utils.timeFromNow(
                                  last?.dateTime.toDateTime, DateTime.now()),
                              style: TextStyle(color: scheme.disabled),
                            ),
                          );
                        });
                  });
            }));
  }
}
