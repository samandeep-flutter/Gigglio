import 'package:get/get.dart';
import 'package:gigglio/view_models/controller/messages_controller/chat_controller.dart';

class MessagesBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
