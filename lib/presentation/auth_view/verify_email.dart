import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/config/routes/routes.dart';
import '../../data/utils/dimens.dart';
import '../../business_logic/auth_controller/signin_controller.dart';
import '../widgets/loading_widgets.dart';

class VerifyEmail extends GetView<SignInController> {
  const VerifyEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        automaticallyImplyLeading: false,
        title: TextButton.icon(
          onPressed: () => controller.fromVerifyEmail(context),
          label: const Text(StringRes.goBack),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: Dimens.sizeDefault,
          ),
        ),
        centerTitle: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder(
              stream: controller.fbAuth.userChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const SizedBox();
                if (snapshot.data?.emailVerified ?? false) {
                  controller.verifyEmailLoading.value = true;
                  Future.delayed(const Duration(seconds: 1)).then((_) {
                    Get.offAllNamed(AppRoutes.rootView);
                  });
                }
                return const SizedBox();
              }),
          const SizedBox(height: Dimens.sizeLarge),
          const Text(
            StringRes.verifyEmail,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: Dimens.fontUltraLarge),
          ),
          const SizedBox(height: Dimens.sizeLarge),
          Text(
            StringRes.verifyEmailDesc,
            style: TextStyle(color: scheme.textColorLight),
          ),
          const Spacer(),
          Obx(() => LoadingButton(
              width: double.infinity,
              enable: controller.verifyEmailEnable.value,
              isLoading: controller.verifyEmailLoading.value,
              onPressed: controller.sendVerificationEmail,
              child: const Text(StringRes.sendEmail))),
          SizedBox(height: context.height * .1),
        ],
      ),
    );
  }
}
