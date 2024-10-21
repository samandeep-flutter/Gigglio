import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/auth_controller/signin_controller.dart';
import '../../model/utils/dimens.dart';
import '../../model/utils/string.dart';
import '../../services/theme_services.dart';
import '../widgets/my_text_field_widget.dart';
import '../widgets/top_widgets.dart';

class ForgotPassword extends GetView<SignInController> {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
        appBar: AppBar(),
        safeAreaBottom: true,
        child: PopScope(
          onPopInvokedWithResult: controller.onForgotPassPop,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const SizedBox(height: Dimens.sizeLarge),
              const Text(
                StringRes.forgotPass,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
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
              SizedBox(
                width: 200,
                child: Obx(() => LoadingButton(
                    isLoading: controller.forgotPassLoading.value,
                    onPressed: controller.sendForgotPassLink,
                    child: const Text(StringRes.submit))),
              ),
              const SizedBox(height: Dimens.sizeLarge),
            ],
          ),
        ));
  }
}
