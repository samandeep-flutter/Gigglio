import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.authServices.user;
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      child: ListView(
        children: [
          const SizedBox(height: Dimens.sizeDefault),
          Obx(() => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyCachedImage(
                    user.value?.image,
                    isAvatar: true,
                    avatarRadius: 50,
                  ),
                  const SizedBox(width: Dimens.sizeLarge),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimens.sizeSmall),
                      Text(
                        user.value?.displayName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: Dimens.fontExtraDoubleLarge,
                            color: scheme.textColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        user.value?.bio ?? user.value?.email ?? '',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: scheme.textColorLight,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  )),
                ],
              )),
          const SizedBox(height: Dimens.sizeLarge),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: buttonStyle(context),
                  onPressed: controller.toEditProfile,
                  label: const Text(StringRes.editProfile),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(width: Dimens.sizeDefault),
              Expanded(
                child: ElevatedButton.icon(
                  style: buttonStyle(context),
                  onPressed: controller.toSettings,
                  label: const Text(StringRes.settings),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.sizeDefault),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () {},
                minVerticalPadding: 0,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                  Dimens.borderSmall,
                )),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: Dimens.sizeSmall),
                leading: const Icon(Icons.people_outline),
                title: const Text(StringRes.friends),
              ),
              SizedBox(height: context.width * .3)
            ],
          ),
          const SizedBox(height: Dimens.sizeDefault),
          Container(
            padding: const EdgeInsets.all(Dimens.sizeSmall),
            decoration: BoxDecoration(
                border: Border.all(color: scheme.disabled.withOpacity(.5)),
                borderRadius: BorderRadius.circular(Dimens.borderSmall)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  onTap: controller.toMyPosts,
                  minVerticalPadding: 0,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                    Dimens.borderSmall,
                  )),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: Dimens.sizeSmall),
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text(StringRes.myPosts),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: Dimens.sizeDefault,
                  ),
                ),
                StreamBuilder(
                    stream: controller.posts
                        .where('author', isEqualTo: user.value!.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const ToolTipWidget();
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SnapshotLoading();
                      }

                      final posts = snapshot.data?.docs.map((e) {
                        return PostModel.fromJson(e.data());
                      }).toList();

                      if (posts?.isEmpty ?? true) return const SizedBox();

                      return SizedBox(
                        height: context.width * .3,
                        child: ListView.builder(
                            padding: const EdgeInsets.only(
                              top: Dimens.sizeSmall,
                            ),
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: posts!.length > 3 ? 4 : posts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: Dimens.sizeExtraSmall - 2,
                                ),
                                child: MyCachedImage(
                                  borderRadius: index == 0
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                          Dimens.sizeSmall,
                                        ))
                                      : null,
                                  posts[index].images.first,
                                  fit: BoxFit.cover,
                                  width: context.width * .3,
                                  height: context.width * .3,
                                ),
                              );
                            }),
                      );
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  ButtonStyle buttonStyle(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return ElevatedButton.styleFrom(
      backgroundColor: scheme.surface,
      elevation: .5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(Dimens.borderSmall),
      )),
      padding: const EdgeInsets.symmetric(vertical: Dimens.sizeMedSmall),
    );
  }
}
