import 'package:get/get.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/home_controller.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/messages_controller.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/profile_controller.dart';
import 'package:gigglio/view_models/controller/root_controller.dart';
import 'package:gigglio/view_models/controller/settings_controller.dart';

class RootBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MessagesController>(() => MessagesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
