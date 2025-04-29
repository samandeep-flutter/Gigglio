import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/business_logic/auth_controller/signin_controller.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../../services/theme_services.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class ForgotPassword extends GetView<SignInController> {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
        appBar: AppBar(backgroundColor: scheme.background),
        safeAreaBottom: true,
        child: PopScope(
          onPopInvokedWithResult: controller.fromForgotPass,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const SizedBox(height: Dimens.sizeLarge),
              const Text(
                StringRes.forgotPass,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimens.fontUltraLarge),
              ),
              const SizedBox(height: Dimens.sizeLarge),
              Text(
                StringRes.forgotPassDesc,
                style: TextStyle(color: scheme.textColorLight),
              ),
              const SizedBox(height: Dimens.sizeExtraLarge),
              MyTextField(
                fieldKey: controller.forgotPassKey,
                title: 'Email',
                isEmail: true,
                controller: controller.forgotPassContr,
              ),
              SizedBox(height: context.height * 0.35),
              Obx(() => LoadingButton(
                  isLoading: controller.forgotPassLoading.value,
                  onPressed: controller.sendForgotPassLink,
                  child: const Text(StringRes.submit))),
              const SizedBox(height: Dimens.sizeLarge),
            ],
          ),
        ));
  }
}
