import 'package:get/get.dart';
import '../controller/settings_controller.dart';

class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
