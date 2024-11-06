import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/image_resources.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view_models/controller/messages_controller/chat_controller.dart';
import '../widgets/my_text_field_widget.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return BaseWidget(
      padding: EdgeInsets.zero,
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
          const Expanded(child: SizedBox()),
          SafeArea(
              minimum: const EdgeInsets.symmetric(vertical: Dimens.sizeSmall),
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
                    onPressed: controller.sendMessage,
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
