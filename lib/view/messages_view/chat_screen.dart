import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/messages_model.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/image_resources.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../view_models/controller/messages_controller/chat_controller.dart';
import '../widgets/my_text_field_widget.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  void _scrollTo(double? to) {
    if (to == null) return;
    if (controller.isScrolled) return;
    const duration = Duration(milliseconds: 500);
    Future.delayed(duration, () {
      if (controller.scrollContr.position.haveDimensions) {
        controller.scrollContr.animateTo(
          to,
          duration: duration,
          curve: Curves.easeOut,
        );
        controller.isScrolled = true;
      }
    });
  }

  _readRecipt(MessagesModel? model) async {
    if (model == null) return;
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      if (controller.scrollContr.position.maxScrollExtent > 0) return;
      final user = controller.authServices.user.value;
      final index = model.users.indexWhere((e) => e.id == user!.id);
      controller.messages
          .doc(controller.chatId)
          .update({'users.$index.seen': model.messages.length});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final user = controller.authServices.user.value;

    MessagesModel? messages;
    return BaseWidget(
      padding: EdgeInsets.zero,
      resizeBottom: false,
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(ImageRes.chatBackground),
        fit: BoxFit.cover,
      )),
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surface,
        shadowColor: scheme.surface,
        elevation: 5,
        titleSpacing: 0,
        title: Row(
          children: [
            MyCachedImage(
              controller.otherUser.image,
              isAvatar: true,
              avatarRadius: 16,
            ),
            const SizedBox(width: Dimens.sizeDefault),
            Text(controller.otherUser.displayName),
          ],
        ),
        centerTitle: false,
      ),
      child: Column(
        children: [
          Expanded(child: Obx(() {
            if (controller.isIdLoading.value) return const SnapshotLoading();

            return StreamBuilder(
                stream: controller.messages.doc(controller.chatId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const ToolTipWidget();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SnapshotLoading();
                  }
                  final json = snapshot.data!.data();
                  messages = MessagesModel.fromJson(json!);

                  if (!controller.isScrolled) {
                    _scrollTo(messages!.users.firstWhere((e) {
                      return e.id != user!.id;
                    }).scrollAt);
                  }
                  final index =
                      messages!.users.indexWhere((e) => e.id == user!.id);

                  if (messages!.users[index].seen !=
                      messages!.messages.length) {
                    _readRecipt(messages);
                  }

                  return ListView.builder(
                      padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                      controller: controller.scrollContr,
                      itemCount: messages!.messages.length,
                      itemBuilder: (context, index) {
                        final message = messages!.messages[index];
                        final time = message.dateTime.toDateTime;
                        final otherUser = messages!.users.firstWhere((e) {
                          return e.id != message.author;
                        });

                        bool isScrolled = otherUser.scrollAt != null &&
                                message.scrollAt != null
                            ? otherUser.scrollAt! >= message.scrollAt!
                            : otherUser.seen >= message.position;

                        return Row(
                          mainAxisAlignment: message.author == user!.id
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: Dimens.sizeDefault),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: Dimens.sizeSmall),
                              decoration: BoxDecoration(
                                  color: message.author == user.id
                                      ? scheme.primaryContainer
                                      : scheme.surface,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(Dimens.borderSmall))),
                              padding: const EdgeInsets.all(Dimens.sizeSmall),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(message.text),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: Dimens.sizeSmall,
                                          top: Dimens.sizeSmall),
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
                                            const SizedBox(
                                                width: Dimens.sizeExtraSmall),
                                            Icon(
                                              Icons.check_rounded,
                                              color: isScrolled
                                                  ? Colors.blue
                                                  : scheme.disabled
                                                      .withOpacity(.7),
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
                      });
                });
          })),
          SafeArea(
              minimum: EdgeInsets.only(
                bottom: context.mediaQuery.viewInsets.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      fieldKey: controller.messageKey,
                      maxLines: 1,
                      backgroundColor: scheme.surface,
                      borderRadius: BorderRadius.circular(Dimens.borderLarge),
                      margin: const EdgeInsets.only(left: Dimens.sizeSmall),
                      title: 'Message',
                      capitalization: TextCapitalization.sentences,
                      controller: controller.messageContr,
                    ),
                  ),
                  const SizedBox(width: Dimens.sizeSmall),
                  IconButton.filled(
                    constraints: const BoxConstraints.expand(
                      height: 52,
                      width: 52,
                    ),
                    onPressed: () => controller.sendMessage(messages),
                    icon: const Icon(Icons.send),
                  ),
                  const SizedBox(width: Dimens.sizeSmall),
                ],
              ))
        ],
      ),
    );
  }
}
