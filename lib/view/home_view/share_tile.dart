import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/home_controllers/home_controller.dart';

import '../widgets/loading_widgets.dart';

class ShareTileSheet extends GetView<HomeController> {
  final VoidCallback onTap;

  const ShareTileSheet({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FutureBuilder(
                future: controller.users.get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const ToolTipWidget();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: Dimens.sizeSmall,
                                mainAxisSpacing: Dimens.sizeSmall),
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const MyCachedImage.loading(
                                isAvatar: true,
                                avatarRadius: 40,
                              ),
                              const SizedBox(height: Dimens.sizeSmall),
                              SizedBox(
                                  height: 10, width: 50, child: Shimmer.box)
                            ],
                          );
                        });
                  }
                  final users = snapshot.data!.docs.map((e) {
                    return UserDetails.fromJson(e.data());
                  }).toList();
                  final cUser = users.firstWhereOrNull((e) {
                    return e.id == controller.authServices.user.value!.id;
                  });

                  users.removeWhere((e) {
                    return !cUser!.friends.contains(e.id);
                  });
                  return GridView.builder(
                      scrollDirection:
                          users.length < 6 ? Axis.vertical : Axis.horizontal,
                      itemCount: users.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: users.length < 6 ? 3 : 2,
                          crossAxisSpacing: Dimens.sizeSmall,
                          mainAxisSpacing: Dimens.sizeSmall),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Obx(
                          () {
                            final selected =
                                controller.shareSel.contains(user.id);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    MyAvatar(
                                      user.image,
                                      isAvatar: true,
                                      avatarRadius: 38,
                                      onTap: () {
                                        if (selected) {
                                          controller.shareSel.remove(user.id);
                                          return;
                                        }
                                        controller.shareSel.add(user.id);
                                      },
                                    ),
                                    if (selected)
                                      Container(
                                        margin: const EdgeInsets.all(
                                            Dimens.sizeExtraSmall),
                                        decoration: BoxDecoration(
                                            color: scheme.background,
                                            borderRadius: BorderRadius.circular(
                                                Dimens.borderLarge)),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: scheme.primary,
                                          size: Dimens.sizeMedium,
                                        ),
                                      )
                                  ],
                                ),
                                const SizedBox(height: Dimens.sizeSmall),
                                Text(
                                  user.displayName,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: Dimens.fontMed,
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      });
                }),
          ),
          Obx(() => LoadingButton(
                width: double.infinity,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                border: Dimens.borderSmall,
                isLoading: controller.shareLoading.value,
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimens.sizeLarge,
                ),
                onPressed: onTap,
                child: const Text(StringRes.share),
              ))
        ],
      ),
    );
  }
}
