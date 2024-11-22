import 'package:get/get.dart';
import 'package:gigglio/view_models/controller/home_controllers/goto_profile_controller.dart';
import 'package:gigglio/view_models/controller/home_controllers/home_controller.dart';
import 'package:gigglio/view_models/controller/messages_controller/messages_controller.dart';
import 'package:gigglio/view_models/controller/profile_controllers/profile_controller.dart';
import 'package:gigglio/view_models/controller/root_controller.dart';

class RootBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MessagesController>(() => MessagesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<GotoProfileController>(() => GotoProfileController());
  }
}
