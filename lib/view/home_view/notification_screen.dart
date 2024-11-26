import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/notification_model.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controllers/home_controller.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_cached_image.dart';

class NotificationScreen extends GetView<HomeController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final user = controller.authServices.user.value;

    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.noti),
          titleTextStyle: Utils.defTitleStyle,
          centerTitle: false,
        ),
        padding: EdgeInsets.zero,
        child: FutureBuilder(
            future: controller.noti
                .where('to', isEqualTo: user!.id)
                .orderBy('to')
                .orderBy('date_time', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const ToolTipWidget();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                  children: List.generate(3, (_) {
                    return UserTileShimmer(
                      title: context.width * .5,
                      avatarRadius: 24,
                      trailing: SizedBox.square(
                        dimension: 40,
                        child: Shimmer.box,
                      ),
                    );
                  }),
                );
              }

              final docs = snapshot.data?.docs;
              List<NotiModel> noti = docs!.map((e) {
                return NotiModel.fromJson(e.data());
              }).toList();
              if (noti.isEmpty) {
                return const ToolTipWidget(title: StringRes.noNoti);
              }
              _saveNotiCount(docs.length);
              return ListView.builder(
                  itemCount: noti.length,
                  padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                  itemBuilder: (context, index) {
                    final item = noti[index];
                    return StreamBuilder(
                        stream: controller.users.doc(item.from).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return UserTileShimmer(
                              title: context.width * .5,
                              avatarRadius: 24,
                              trailing: SizedBox.square(
                                dimension: 40,
                                child: Shimmer.box,
                              ),
                            );
                          }
                          final json = snapshot.data?.data();
                          final author = UserDetails.fromJson(json!);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimens.sizeExtraSmall),
                            child: ListTile(
                              leading: MyAvatar(
                                author.image,
                                isAvatar: true,
                                avatarRadius: 24,
                                id: author.id,
                              ),
                              horizontalTitleGap: Dimens.sizeSmall,
                              title: MyRichText(
                                  style: TextStyle(
                                      color: scheme.textColor,
                                      fontSize: Dimens.fontDefault),
                                  maxLines: 3,
                                  children: [
                                    TextSpan(
                                        text: author.displayName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const WidgetSpan(child: SizedBox(width: 4)),
                                    TextSpan(text: item.category.desc)
                                  ]),
                              trailing: item.category == NotiCategory.request
                                  ? LoadingButton(
                                      isLoading: false,
                                      compact: true,
                                      border: Dimens.borderSmall,
                                      foregroundColor: scheme.primaryContainer,
                                      backgroundColor:
                                          scheme.onPrimaryContainer,
                                      enable: !author.friends.contains(user.id),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Dimens.sizeSmall),
                                      defWidth: true,
                                      onPressed: () =>
                                          controller.acceptReq(author.id),
                                      child: Text(
                                          author.friends.contains(user.id)
                                              ? StringRes.accepted
                                              : StringRes.accept))
                                  : FutureBuilder(
                                      future: controller.posts
                                          .doc(item.postId)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError ||
                                            snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                          return MyCachedImage.loading(
                                            borderRadius: BorderRadius.circular(
                                                Dimens.borderDefault),
                                          );
                                        }
                                        final json = snapshot.data?.data();
                                        final post = PostModel.fromJson(json!);
                                        return MyAvatar(
                                          post.images.first,
                                          borderRadius: Dimens.borderDefault,
                                          onTap: () =>
                                              controller.gotoPost(item.postId!),
                                        );
                                      }),
                            ),
                          );
                        });
                  });
            }));
  }

  void _saveNotiCount(int count) {
    final user = controller.authServices.user.value;
    final doc = controller.users.doc(user!.id);
    doc.update({'noti_seen_count': count});
  }
}
