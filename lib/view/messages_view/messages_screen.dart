import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_text_field_widget.dart';
import 'package:gigglio/view_models/controller/messages_controller/messages_controller.dart';
import '../../services/theme_services.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.messages),
          actions: [
            TextButton.icon(
              onPressed: controller.newChat,
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
                controller: controller.searchController,
                onClear: controller.onClear,
              )),
        ),
        child: const Column());
  }
}
