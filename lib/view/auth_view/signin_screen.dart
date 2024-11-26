import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/image_resources.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import '../../view_models/controller/auth_controller/signin_controller.dart';
import '../../view_models/routes/routes.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

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
                StringRes.signin,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Dimens.fontTitle),
              ),
              const SizedBox(height: Dimens.sizeLarge),
              Text(
                StringRes.signinDesc,
                style: TextStyle(color: scheme.textColorLight),
              ),
              const SizedBox(height: Dimens.sizeExtraLarge),
              MyTextField(
                title: 'Email',
                isEmail: true,
                controller: controller.emailController,
              ),
              const SizedBox(height: Dimens.sizeLarge),
              MyTextField(
                title: 'Password',
                obscureText: true,
                controller: controller.passwordController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: controller.forgotPass,
                      child: const Text('${StringRes.forgotPass}?'))
                ],
              ),
              const SizedBox(height: Dimens.sizeMidLarge),
              Obx(() => LoadingButton(
                  isLoading: controller.signInLoading.value,
                  onPressed: controller.onSumbit,
                  child: const Text(StringRes.signin))),
              const SizedBox(height: Dimens.sizeDefault),
              Text(StringRes.continueWith,
                  style: TextStyle(color: scheme.disabled)),
              const SizedBox(height: Dimens.sizeMedSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => LoadingIcon(
                        buttonStyle: IconButtonStyle.outlined,
                        loading: controller.googleLoading.value,
                        onPressed: controller.googleSignin,
                        icon:
                            Image.asset(ImageRes.google, height: 24, width: 24),
                      )),
                  const SizedBox(width: Dimens.sizeDefault),
                  Obx(() => LoadingIcon(
                        buttonStyle: IconButtonStyle.outlined,
                        loading: controller.twitterLoading.value,
                        onPressed: controller.twitterLogin,
                        icon: Image.asset(ImageRes.twitter,
                            height: 24, width: 24),
                      )),
                ],
              ),
              const SizedBox(height: Dimens.sizeLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(StringRes.noAcc),
                  TextButton(
                      onPressed: () => Get.toNamed(Routes.signUp),
                      child: const Text(StringRes.createAcc))
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
