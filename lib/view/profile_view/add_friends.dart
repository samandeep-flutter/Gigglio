import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/profile_controllers/profile_controller.dart';
import '../../services/theme_services.dart';
import '../widgets/base_widget.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/my_text_field_widget.dart';

class AddFriends extends GetView<ProfileController> {
  const AddFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final bodyTextStyle = context.textTheme.bodyMedium;

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.addFriends),
        titleTextStyle: Utils.defTitleStyle,
      ),
      child: PopScope(
        onPopInvokedWithResult: controller.fromFriends,
        child: Column(
          children: [
            SearchTextField(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimens.sizeDefault,
              ),
              title: 'Search',
              controller: controller.friendContr,
              showClear: false,
            ),
            Expanded(
              child: StreamBuilder(
                  stream: controller.users.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const SizedBox.shrink();
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const SizedBox(height: Dimens.sizeLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 100,
                                child: Shimmer.box,
                              ),
                              const SizedBox(width: Dimens.sizeDefault)
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                                padding: const EdgeInsets.only(
                                    top: Dimens.sizeDefault),
                                itemCount: 3,
                                itemBuilder: (context, _) {
                                  return UserTileShimmer(
                                    avatarRadius: 24,
                                    trailing: SizedBox(
                                      height: 30,
                                      width: 40,
                                      child: Shimmer.box,
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
                    }

                    controller.allUsers.value = snapshot.data!.docs.map((e) {
                      return UserDetails.fromJson(e.data());
                    }).toList();
                    final cUser = controller.allUsers.firstWhere((e) {
                      return e.id == controller.authServices.user.value!.id;
                    });
                    final requests = controller.allUsers
                        .firstWhere((e) {
                          return e.id == cUser.id;
                        })
                        .requests
                        .length;
                    controller.allUsers.removeWhere((e) {
                      return e.id == cUser.id;
                    });

                    controller.friendsList.value =
                        controller.allUsers.where((e) {
                      return cUser.friends.contains(e.id);
                    }).toList();

                    controller.onSearch();

                    return Obx(() {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: controller.toViewRequests,
                                  child: Text('${StringRes.viewRequests} '
                                      '($requests)'))
                            ],
                          ),
                          if (controller.searchedUsers.isEmpty)
                            ToolTipWidget(
                              title: controller.friendContr.text.isEmpty
                                  ? StringRes.addFriendsDesc
                                  : StringRes.noResults,
                              margin: EdgeInsets.symmetric(
                                vertical: context.height * .1,
                                horizontal: Dimens.sizeLarge,
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                                itemCount: controller.searchedUsers.length,
                                itemBuilder: (context, index) {
                                  final user = controller.searchedUsers[index];
                                  return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: Dimens.sizeLarge,
                                      ),
                                      leading: InkWell(
                                        onTap: () =>
                                            controller.gotoProfile(user.id),
                                        splashColor:
                                            scheme.disabled.withOpacity(.7),
                                        borderRadius: BorderRadius.circular(
                                            Dimens.sizeMidLarge),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: MyCachedImage(
                                            user.image,
                                            isAvatar: true,
                                            avatarRadius: 24,
                                          ),
                                        ),
                                      ),
                                      title: Text(user.displayName),
                                      subtitle: Text(
                                        user.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitleTextStyle:
                                          bodyTextStyle?.copyWith(
                                        color: scheme.disabled,
                                      ),
                                      trailing: _TrailingButton(
                                        user: cUser,
                                        other: user,
                                        onTap: () =>
                                            controller.sendReq(user.id),
                                      ));
                                }),
                          ),
                        ],
                      );
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailingButton extends StatelessWidget {
  final UserDetails user;
  final UserDetails other;
  final VoidCallback onTap;

  const _TrailingButton({
    required this.user,
    required this.other,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    if (user.friends.contains(other.id)) return const SizedBox();
    final enable =
        other.requests.contains(user.id) || user.requests.contains(other.id);
    return LoadingButton(
        enable: !enable,
        defWidth: true,
        isLoading: false,
        onPressed: onTap,
        compact: true,
        border: Dimens.borderSmall,
        backgroundColor: scheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.sizeSmall),
        child: Text(other.requests.contains(user.id)
            ? StringRes.requested
            : user.requests.contains(other.id)
                ? StringRes.inReq
                : StringRes.send));
  }
}
