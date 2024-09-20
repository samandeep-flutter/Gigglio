import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gigglio/view_models/routes/routes.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onSumbit() {
    // if (!(formKey.currentState?.validate() ?? true)) return;

    Get.toNamed(Routes.rootView);
  }

  void forgotPass() {}
  void googleLogin() {}
  void appleLogin() {}
}
