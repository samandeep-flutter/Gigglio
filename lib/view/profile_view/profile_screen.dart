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
import 'package:gigglio/view_models/controller/profile_controller.dart';

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
          Obx(() => Row(
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
                        Expanded(
                          flex: 4,
                          child: Text(
                            authServices.user.value?.displayName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: Dimens.fontExtraDoubleLarge,
                                color: scheme.textColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (!(authServices.user.value?.verified ?? false)) ...[
                          const SizedBox(width: Dimens.sizeSmall),
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.all(Dimens.sizeSmall),
                              decoration: const BoxDecoration(
                                  color: ColorRes.tertiaryContainer,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Dimens.borderLarge))),
                              child: const Tooltip(
                                message: StringRes.emailConfirmDesc,
                                triggerMode: TooltipTriggerMode.tap,
                                showDuration: Duration(seconds: 5),
                                margin: EdgeInsets.symmetric(
                                    horizontal: Dimens.sizeExtraDoubleLarge),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: Dimens.sizeMedium,
                                        color: ColorRes.onTertiaryContainer,
                                      ),
                                      SizedBox(width: Dimens.sizeSmall),
                                      Text(StringRes.notVerified,
                                          style: TextStyle(
                                            fontSize: Dimens.fontMed,
                                            color: ColorRes.onTertiaryContainer,
                                          )),
                                    ]),
                              ),
                            ),
                          ),
                        ]
                      ]),
                      Text(
                        authServices.user.value?.email ?? '',
                        style: TextStyle(
                            color: scheme.textColorLight,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ))
                ],
              )),
          const SizedBox(height: Dimens.sizeLarge),
          const MyDivider(),
          const SizedBox(height: Dimens.sizeSmall),
          Card(
            color: scheme.surface,
            child: Column(
              children: [
                const SizedBox(height: Dimens.sizeSmall),
                MyListTile(
                  title: StringRes.editProfile,
                  leading: Icons.edit_outlined,
                  foregroundColor: scheme.textColorLight,
                  onTap: controller.toEditProfile,
                ),
                const MyDivider(margin: Dimens.sizeDefault),
                MyListTile(
                  title: StringRes.changePass,
                  leading: Icons.password,
                  foregroundColor: scheme.textColorLight,
                  onTap: controller.toChangePassword,
                ),
                // const MyDivider(margin: Dimens.sizeDefault),
                // MyListTile(
                //   title: StringRes.myPosts,
                //   leading: Icons.perm_media_outlined,
                //   foregroundColor: scheme.textColorLight,
                //   onTap: controller.toMyPosts,
                // ),
                const SizedBox(height: Dimens.sizeSmall),
              ],
            ),
          ),
          const SizedBox(height: Dimens.sizeSmall),
          const MyDivider(),
          const SizedBox(height: Dimens.sizeSmall),
          MyListTile(
            title: StringRes.settings,
            leading: Icons.settings_outlined,
            foregroundColor: scheme.textColorLight,
            onTap: controller.toSettings,
          ),
          MyListTile(
            title: StringRes.privacyPolicy,
            leading: Icons.privacy_tip_outlined,
            foregroundColor: scheme.textColorLight,
            onTap: controller.toPrivacyPolicy,
          ),
          MyListTile(
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
