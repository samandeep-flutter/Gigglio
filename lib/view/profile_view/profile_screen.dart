import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.authServices.user;
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const SizedBox(height: Dimens.sizeMidLarge),
          Obx(() => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: Dimens.sizeLarge),
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
                        user.value!.email,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: scheme.textColorLight,
                            fontSize: Dimens.fontMed),
                      ),
                      const SizedBox(height: Dimens.sizeSmall + 2),
                      Text(
                        user.value?.bio ?? '',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: scheme.textColorLight,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: Dimens.sizeDefault),
                      StreamBuilder(
                          stream:
                              controller.users.doc(user.value!.id).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return const SizedBox();

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Row(
                                children: List.generate(2, (_) {
                                  return Expanded(
                                      child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Shimmer.box),
                                      const SizedBox(height: Dimens.sizeSmall),
                                      SizedBox(
                                          height: 10,
                                          width: 50,
                                          child: Shimmer.box),
                                    ],
                                  ));
                                }),
                              );
                            }
                            final json = snapshot.data?.data();
                            final user = UserDetails.fromJson(json!);
                            return Row(
                              children: [
                                Expanded(
                                  child: FriendsTile(
                                      title: user.friends.length == 1
                                          ? 'Friend'
                                          : 'Friends',
                                      count: user.friends.length,
                                      onTap: controller.toFriends),
                                ),
                                Expanded(
                                  child: FriendsTile(
                                    title: user.requests.length == 1
                                        ? 'Request'
                                        : 'Requests',
                                    count: user.requests.length,
                                    enable: user.requests.isNotEmpty,
                                    onTap: controller.toViewRequests,
                                  ),
                                )
                              ],
                            );
                          })
                    ],
                  )),
                  const SizedBox(width: Dimens.sizeLarge),
                ],
              )),
          const SizedBox(height: Dimens.sizeLarge),
          Row(
            children: [
              const SizedBox(width: Dimens.sizeLarge),
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
              const SizedBox(width: Dimens.sizeLarge),
            ],
          ),
          const SizedBox(height: Dimens.sizeLarge),
          const ListTile(
            minVerticalPadding: 0,
            visualDensity: VisualDensity.compact,
            leading: Icon(Icons.photo_library_outlined),
            title: Text(StringRes.myPosts),
          ),
          StreamBuilder(
              stream: controller.posts
                  .where('author', isEqualTo: user.value!.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const ToolTipWidget();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimens.sizeExtraSmall),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, _) {
                          return const MyCachedImage.loading();
                        }),
                  );
                }

                final posts = snapshot.data?.docs.map((e) {
                  return PostModel.fromJson(e.data());
                }).toList();

                if (posts?.isEmpty ?? true) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: context.height * .05),
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 150,
                        color: Colors.grey[300],
                      ),
                      const Text(StringRes.noPosts),
                    ],
                  );
                }

                return Expanded(
                  child: GridView.builder(
                      padding: const EdgeInsets.all(Dimens.sizeExtraSmall),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: posts!.length,
                      itemBuilder: (context, index) {
                        final id = snapshot.data?.docs[index].id;
                        return InkWell(
                          onTap: () => controller.toPost(id),
                          splashColor: Colors.black38,
                          child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: MyCachedImage(posts[index].images.first)),
                        );
                      }),
                );
              })
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

class FriendsTile extends StatelessWidget {
  final String title;
  final int count;
  final bool enable;
  final VoidCallback? onTap;

  const FriendsTile({
    super.key,
    required this.title,
    required this.count,
    this.onTap,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    String num = _format(count);
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.borderSmall),
      onTap: enable ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: Dimens.fontExtraTripleLarge,
                  fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: Dimens.fontMed)),
          const SizedBox(height: Dimens.sizeExtraSmall),
        ],
      ),
    );
  }

  String _format(int count) {
    if (count > 999999) {
      String newCount = (count / 1000000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}M';
    }
    if (count > 999) {
      String newCount = (count / 1000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}K';
    }
    return count.toString();
  }
}
