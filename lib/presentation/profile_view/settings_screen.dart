import 'package:flutter/material.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/loading_widgets.dart';
import 'package:gigglio/presentation/widgets/my_alert_dialog.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/color_resources.dart';
import '../../data/utils/dimens.dart';
import '../widgets/top_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

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
              padding: Utils.paddingHoriz(Dimens.sizeSmall),
              child: Column(
                children: [
                  const SizedBox(height: Dimens.sizeSmall),
                  CustomListTile(
                    title: StringRes.editProfile,
                    leading: Icons.edit_outlined,
                    foregroundColor: scheme.textColorLight,
                    onTap: () => context.pushNamed(AppRoutes.editProfile),
                  ),
                  const MyDivider(margin: Dimens.sizeDefault),
                  CustomListTile(
                    title: StringRes.changePass,
                    leading: Icons.password,
                    foregroundColor: scheme.textColorLight,
                    onTap: () => context.pushNamed(AppRoutes.changePass),
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
            onTap: () => context.pushNamed(AppRoutes.privacyPolicy),
          ),
          CustomListTile(
            title: StringRes.logout,
            foregroundColor: scheme.textColorLight,
            iconColor: ColorRes.error,
            splashColor: ColorRes.onError,
            leading: Icons.logout,
            onTap: () => logout(context),
          )
        ],
      ),
    );
  }

  void logout(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return MyAlertDialog(
            title: '${StringRes.logout}?',
            content: const Text(StringRes.logoutDesc),
            actions: [
              TextButton(
                  onPressed: getIt<AuthServices>().logout,
                  style: TextButton.styleFrom(foregroundColor: ColorRes.error),
                  child: Text(StringRes.logout.toUpperCase())),
              LoadingButton(
                compact: true,
                defWidth: true,
                onPressed: context.pop,
                border: Dimens.borderSmall,
                child: Text(StringRes.cancel),
              ),
            ],
          );
        });
  }
}
