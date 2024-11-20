import 'package:get/get.dart';
import 'package:gigglio/view_models/controller/home_controllers/add_post_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPostController>(() => AddPostController());
  }
}
