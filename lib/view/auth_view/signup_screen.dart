import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import '../../model/utils/dimens.dart';
import '../../model/utils/string.dart';
import '../../view_models/controller/auth_controller/signup_controller.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return BaseWidget(
        child: Form(
      key: controller.formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                StringRes.signup,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Dimens.fontTitle),
              ),
              const SizedBox(height: Dimens.sizeLarge),
              Text(
                StringRes.singupDesc,
                style: TextStyle(color: scheme.textColorLight),
              ),
              const SizedBox(height: Dimens.sizeExtraLarge),
              MyTextField(
                title: 'Name',
                controller: controller.nameController,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: Dimens.sizeLarge),
              MyTextField(
                title: 'Email',
                isEmail: true,
                controller: controller.emailController,
              ),
              const SizedBox(height: Dimens.sizeLarge),
              MyTextField(
                title: 'Password',
                obscureText: true,
                isPass: true,
                controller: controller.passController,
              ),
              const SizedBox(height: Dimens.sizeSmall),
              Text(
                StringRes.newPassDesc,
                style: TextStyle(color: scheme.textColorLight),
              ),
              const SizedBox(height: Dimens.sizeDefault),
              MyTextField(
                title: 'Confirm Password',
                obscureText: true,
                controller: controller.confirmPassController,
                customValidator: (value) {
                  if (value?.isEmpty ?? true) {
                    return StringRes.errorEmpty('Confirm Password');
                  } else if (value != controller.passController.text) {
                    return StringRes.errorPassMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimens.sizeExtraLarge),
              Obx(() => LoadingButton(
                  isLoading: controller.isLoading.value,
                  onPressed: controller.onSumbit,
                  child: const Text(StringRes.signup))),
              const SizedBox(height: Dimens.sizeSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(StringRes.accAlready),
                  TextButton(
                      onPressed: Get.back, child: const Text(StringRes.signin))
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
