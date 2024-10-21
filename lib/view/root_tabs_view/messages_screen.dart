import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_text_field_widget.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/messages_controller.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        appBar: AppBar(
          title: const Text(StringRes.messages),
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
