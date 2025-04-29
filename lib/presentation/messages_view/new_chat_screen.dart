import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/models/user_details.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/business_logic/messages_controller/messages_controller.dart';
import '../../data/utils/string.dart';
import '../widgets/my_text_field_widget.dart';

class NewChatScreen extends GetView<MessagesController> {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final bodyTextStyle = context.textTheme.bodyMedium;

    return BaseWidget(
        padding: EdgeInsets.zero,
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: SearchTextField(
            title: 'Search',
            focusNode: controller.newChatFocus,
            controller: controller.newChatContr,
            showClear: false,
          ),
          titleSpacing: 0,
          actions: const [SizedBox(width: Dimens.sizeDefault)],
        ),
        child: FutureBuilder(
            future: controller.users.get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const ToolTipWidget();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  padding: const EdgeInsets.only(top: Dimens.sizeLarge),
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(3, (_) {
                    return const UserTileShimmer(
                      avatarRadius: 24,
                      trailing: SizedBox(),
                    );
                  }),
                );
              }

              controller.allUsers.value = snapshot.data!.docs.map((e) {
                return UserDetails.fromJson(e.data());
              }).toList();

              final cUser = controller.allUsers.firstWhere((e) {
                return e.id == controller.authServices.user.value!.id;
              });
              controller.allUsers.removeWhere((e) {
                return !cUser.friends.contains(e.id);
              });

              controller.onUserSearch();

              if (controller.usersList.isEmpty) {
                return ToolTipWidget(
                  title: StringRes.noFriends,
                  margin: EdgeInsets.symmetric(
                    horizontal: Dimens.sizeLarge,
                    vertical: context.height * .1,
                  ),
                );
              }
              return Obx(() => ListView.builder(
                  padding: const EdgeInsets.only(top: Dimens.sizeLarge),
                  itemCount: controller.usersList.length,
                  itemBuilder: (context, index) {
                    final user = controller.usersList[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimens.sizeLarge,
                      ),
                      onTap: () => controller.toChatScreen(user, replace: true),
                      leading: MyAvatar(
                        user.image,
                        isAvatar: true,
                        avatarRadius: 24,
                        id: user.id,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(user.bio ?? StringRes.defBio),
                      subtitleTextStyle: bodyTextStyle?.copyWith(
                        color: scheme.disabled,
                      ),
                    );
                  }));
            }));
  }
}
