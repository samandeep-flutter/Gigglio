import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/settings_controller.dart';
import '../model/utils/color_resources.dart';
import '../model/utils/dimens.dart';
import '../services/theme_services.dart';
import 'widgets/top_widgets.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.settings),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: true,
      ),
      child: Column(
        children: [
          const SizedBox(height: Dimens.sizeSmall),
          Card(
            color: scheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.sizeSmall),
              child: Column(
                children: [
                  const SizedBox(height: Dimens.sizeSmall),
                  // const MyDivider(margin: Dimens.sizeDefault),
                  CustomListTile(
                    title: StringRes.changePass,
                    leading: Icons.password,
                    foregroundColor: scheme.textColorLight,
                    onTap: controller.toChangePassword,
                  ),
                  const SizedBox(height: Dimens.sizeSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimens.sizeSmall),
          const MyDivider(),
          const SizedBox(height: Dimens.sizeSmall),
          CustomListTile(
            title: StringRes.privacyPolicy,
            leading: Icons.privacy_tip_outlined,
            foregroundColor: scheme.textColorLight,
            onTap: controller.toPrivacyPolicy,
          ),
          CustomListTile(
            title: StringRes.logout,
            foregroundColor: scheme.textColorLight,
            iconColor: ColorRes.onErrorContainer,
            splashColor: ColorRes.errorContainer,
            leading: Icons.logout,
            onTap: () => controller.logout(context),
          )
        ],
      ),
    );
  }
}
