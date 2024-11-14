import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';

import '../../model/utils/app_constants.dart';
import '../../model/utils/color_resources.dart';
import '../../model/utils/string.dart';
import '../../services/auth_services.dart';
import '../../services/theme_services.dart';
import '../routes/routes.dart';

class SettingsController extends GetxController {
  AuthServices authServices = Get.find();
  final _user = FirebaseAuth.instance.currentUser;

  final changePassKey = GlobalKey<FormState>();
  final oldPassContr = TextEditingController();
  final newPassContr = TextEditingController();
  final confirmPassContr = TextEditingController();

  RxBool isChangePassLoading = RxBool(false);

  void toChangePassword() => Get.toNamed(Routes.changePass);
  void toPrivacyPolicy() => Get.toNamed(Routes.privacyPolicy);

  void fromChangePass(bool canPop, result) =>
      changePassKey.currentState?.reset();

  void changePassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(changePassKey.currentState?.validate() ?? false)) return;
    isChangePassLoading.value = true;
    try {
      await _user!.updatePassword(confirmPassContr.text);
    } on FirebaseAuthException catch (e) {
      isChangePassLoading.value = false;
      logPrint('ChangePass: $e');
      if (e.code == 'requires-recent-login') {
        showDialog(
            context: Get.context!,
            builder: (context) {
              return MyAlertDialog(
                title: 'Re-Authenticate',
                content: const Text(StringRes.reauthDesc),
                actions: [
                  TextButton(
                    onPressed: Get.back,
                    child: const Text(StringRes.cancel),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: authServices.logout,
                    child: const Text('Re-Authenticate'),
                  ),
                ],
              );
            });
      }
    } catch (e) {
      isChangePassLoading.value = false;
      logPrint('ChangePass: $e');
    }
  }

  void logout(BuildContext context) {
    final scheme = ThemeServices.of(context);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return MyAlertDialog(
            title: '${StringRes.logout}?',
            content: const Text(StringRes.logoutDesc),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: scheme.textColorLight),
                onPressed: Get.back,
                child: Text(StringRes.cancel.toUpperCase()),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: ColorRes.onErrorContainer),
                  onPressed: authServices.logout,
                  child: Text(StringRes.logout.toUpperCase())),
            ],
          );
        });
  }
}
