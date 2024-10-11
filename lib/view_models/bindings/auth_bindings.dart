import 'package:get/get.dart';
import '../controller/auth_controller/signin_controller.dart';
import '../controller/auth_controller/signup_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}
