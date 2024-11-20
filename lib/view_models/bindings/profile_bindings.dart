import 'package:get/get.dart';
import 'package:gigglio/view_models/controller/profile_controllers/edit_profile_controller.dart';
import '../controller/settings_controller.dart';

class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
