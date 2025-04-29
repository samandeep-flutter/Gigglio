import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/business_logic/profile_controllers/settings_controller.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../../services/theme_services.dart';
import '../widgets/base_widget.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class ChangePassword extends GetView<SettingsController> {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      appBar: AppBar(backgroundColor: scheme.background),
      child: PopScope(
        onPopInvokedWithResult: controller.fromChangePass,
        child: Center(
          child: Form(
            key: controller.changePassKey,
            child: ListView(
              children: [
                const SizedBox(height: Dimens.sizeExtraLarge),
                const Text(
                  StringRes.changePass,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Dimens.fontUltraLarge),
                ),
                const SizedBox(height: Dimens.sizeSmall),
                Text(
                  StringRes.newPassDesc,
                  style: TextStyle(color: scheme.textColorLight),
                ),
                const SizedBox(height: Dimens.sizeLarge),
                MyTextField(
                  title: 'New Password',
                  isPass: true,
                  obscureText: true,
                  controller: controller.newPassContr,
                ),
                const SizedBox(height: Dimens.sizeLarge),
                MyTextField(
                  title: 'Confirm Password',
                  isPass: true,
                  obscureText: true,
                  controller: controller.confirmPassContr,
                  customValidator: (value) {
                    if (value?.isEmpty ?? true) {
                      return StringRes.errorEmpty('Confirm Password');
                    } else if (controller.newPassContr.text != value) {
                      return StringRes.errorPassMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: Dimens.sizeExtraLarge),
                Obx(() => LoadingButton(
                    isLoading: controller.isChangePassLoading.value,
                    onPressed: controller.changePassword,
                    child: const Text(StringRes.submit))),
                const SizedBox(height: Dimens.sizeLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
