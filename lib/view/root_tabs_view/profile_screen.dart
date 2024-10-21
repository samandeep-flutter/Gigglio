import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/color_resources.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/profile_controller.dart';
import 'package:gigglio/view_models/routes/routes.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthServices authServices = Get.find();
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      child: Column(
        children: [
          const SizedBox(height: Dimens.sizeLarge),
          Row(
            children: [
              MyCachedImage(
                authServices.user.value?.image,
                isAvatar: true,
                avatarRadius: 50,
              ),
              const SizedBox(width: Dimens.sizeLarge),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      authServices.user.value?.displayName ?? '',
                      style: TextStyle(
                          fontSize: Dimens.fontExtraDoubleLarge,
                          color: scheme.textColor,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: Dimens.sizeSmall),
                    // if (!(authServices.user.value?.verified ?? false))
                    TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: ColorRes.onTertiaryContainer,
                          backgroundColor: ColorRes.tertiaryContainer,
                          textStyle: const TextStyle(fontSize: Dimens.fontMed),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.sizeSmall,
                          ),
                        ),
                        icon: const Icon(
                          Icons.email_outlined,
                          size: Dimens.sizeMedium,
                        ),
                        label: const Text(StringRes.notVerified)),
                  ]),
                  Text(
                    authServices.user.value?.email ?? '',
                    style: TextStyle(
                        color: scheme.textColorLight,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: Dimens.sizeLarge),
          const MyDivider(),
          const SizedBox(height: Dimens.sizeSmall),
          Card(
            color: scheme.background,
            child: Column(
              children: [
                const SizedBox(height: Dimens.sizeSmall),
                MyListTile(
                  title: StringRes.editProfile,
                  leading: Icons.edit_outlined,
                  foregroundColor: scheme.textColorLight,
                  onTap: () {},
                ),
                const MyDivider(margin: Dimens.sizeDefault),
                MyListTile(
                  title: StringRes.changePass,
                  leading: Icons.password,
                  foregroundColor: scheme.textColorLight,
                  onTap: () {},
                ),
                const MyDivider(margin: Dimens.sizeDefault),
                MyListTile(
                  title: StringRes.myPosts,
                  leading: Icons.perm_media_outlined,
                  foregroundColor: scheme.textColorLight,
                  onTap: () {},
                ),
                const SizedBox(height: Dimens.sizeSmall),
              ],
            ),
          ),
          const SizedBox(height: Dimens.sizeSmall),
          const MyDivider(),
          const SizedBox(height: Dimens.sizeSmall),
          MyListTile(
            title: StringRes.privacyPolicy,
            leading: Icons.privacy_tip_outlined,
            foregroundColor: scheme.textColorLight,
            onTap: () => Get.toNamed(Routes.settings),
          ),
          MyListTile(
            title: StringRes.logout,
            foregroundColor: scheme.textColorLight,
            iconColor: ColorRes.onErrorContainer,
            splashColor: ColorRes.errorContainer,
            leading: Icons.logout,
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return MyAlertDialog(
                      title: '${StringRes.logout}?',
                      content: const Text(StringRes.logoutText),
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
            },
          )
        ],
      ),
    );
  }
}

class MyListTile extends StatelessWidget {
  final String? title;
  final Color? foregroundColor;
  final IconData? leading;
  final Widget? trailing;
  final Color? splashColor;
  final EdgeInsets? margin;
  final Color? iconColor;
  final VoidCallback? onTap;
  const MyListTile({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.foregroundColor,
    this.margin,
    this.splashColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        visualDensity: VisualDensity.compact,
        splashColor: splashColor,
        textColor: foregroundColor,
        iconColor: iconColor ?? foregroundColor,
        minVerticalPadding: 0,
        title: Text(title ?? ''),
        leading: Icon(leading, size: Dimens.sizeMedium),
        trailing: trailing,
      ),
    );
  }
}
