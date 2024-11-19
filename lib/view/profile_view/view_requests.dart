import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../model/utils/dimens.dart';
import '../../model/utils/string.dart';
import '../../model/utils/utils.dart';
import '../../view_models/controller/profile_controller.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/shimmer_widget.dart';

class ViewRequests extends GetView<ProfileController> {
  const ViewRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final bodyTextStyle = context.textTheme.bodyMedium;

    return BaseWidget(
        padding: EdgeInsets.zero,
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.viewRequests),
          titleTextStyle: Utils.defTitleStyle,
        ),
        child: FutureBuilder(
            future: controller.users.get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const ToolTipWidget();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                    itemCount: 3,
                    padding: const EdgeInsets.only(top: Dimens.sizeLarge),
                    itemBuilder: (context, _) {
                      return UserTileShimmer(
                        avatarRadius: 24,
                        trailing: SizedBox(
                          height: 30,
                          width: 40,
                          child: Shimmer.box,
                        ),
                      );
                    });
              }
              final users = snapshot.data?.docs.map((e) {
                return UserDetails.fromJson(e.data());
              }).toList();
              final cUser = users?.firstWhere((e) {
                return e.id == controller.authServices.user.value!.id;
              });
              users!.removeWhere((e) {
                return !cUser!.requests.contains(e.id);
              });
              controller.reqAccepted.value =
                  List<bool>.generate(users.length, (_) => false);

              return ListView.builder(
                  padding: const EdgeInsets.only(top: Dimens.sizeLarge),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Dimens.sizeLarge,
                        ),
                        leading: MyCachedImage(
                          user.image,
                          isAvatar: true,
                          avatarRadius: 24,
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitleTextStyle: bodyTextStyle?.copyWith(
                          color: scheme.disabled,
                        ),
                        trailing: Obx(() => _TrailingButton(
                            sent: controller.reqAccepted[index],
                            onTap: () => controller.acceptRequest(
                                  user.id,
                                  index: index,
                                ))));
                  });
            }));
  }
}

class _TrailingButton extends GetView<ProfileController> {
  final VoidCallback onTap;
  final bool sent;

  const _TrailingButton({
    required this.onTap,
    required this.sent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    if (sent) return const SizedBox();

    return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.sizeSmall),
            foregroundColor: scheme.primaryContainer,
            backgroundColor: scheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.borderSmall)),
            visualDensity: VisualDensity.compact),
        child: const Text(StringRes.accept));
  }
}
