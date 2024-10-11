import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/messages_controller.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      appBar: AppBar(),
      child: const Center(
        child: Text('Messages'),
      ),
    );
  }
}
