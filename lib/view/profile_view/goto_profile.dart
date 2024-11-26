import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/home_controllers/goto_profile_controller.dart';
import '../../model/models/post_model.dart';
import '../../model/models/user_details.dart';
import '../../model/utils/dimens.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/shimmer_widget.dart';

class GotoProfile extends GetView<GotoProfileController> {
  const GotoProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final userId = controller.userId;
    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: StreamBuilder(
              stream: controller.users.doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const SizedBox.shrink();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(height: 20, width: 100, child: Shimmer.box);
                }
                final json = snapshot.data?.data();
                final user = UserDetails.fromJson(json!);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName,
                        style: Utils.defTitleStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                      user.email,
                      style: TextStyle(
                          fontSize: Dimens.fontMed,
                          color: scheme.textColorLight),
                    ),
                  ],
                );
              }),
          centerTitle: false,
        ),
        padding: EdgeInsets.zero,
        child: ListView(
          children: [
            const SizedBox(height: Dimens.sizeLarge),
            FutureBuilder(
                future: controller.users.doc(userId).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const SizedBox.shrink();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: Dimens.sizeLarge),
                        const MyCachedImage.loading(
                          isAvatar: true,
                          avatarRadius: 50,
                        ),
                        const SizedBox(width: Dimens.sizeLarge),
                        Expanded(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(2, (_) {
                              return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  width: double.infinity,
                                  height: 15,
                                  child: Shimmer.box);
                            }),
                            const SizedBox(height: Dimens.sizeDefault),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 50,
                                  child: Shimmer.box,
                                ),
                                SizedBox(
                                  height: 60,
                                  width: 50,
                                  child: Shimmer.box,
                                ),
                              ],
                            )
                          ],
                        )),
                        const SizedBox(width: Dimens.sizeLarge),
                      ],
                    );
                  }
                  final json = snapshot.data?.data();
                  final user = UserDetails.fromJson(json!);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: Dimens.sizeLarge),
                      MyCachedImage(
                        user.image,
                        isAvatar: true,
                        avatarRadius: 50,
                      ),
                      const SizedBox(width: Dimens.sizeLarge),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.bio ?? '',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: scheme.textColorLight,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: Dimens.sizeDefault),
                          Row(
                            children: [
                              FutureBuilder(
                                  future: controller.posts
                                      .where('author', isEqualTo: userId)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError ||
                                        snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                      return SizedBox(
                                          height: 60,
                                          width: 50,
                                          child: Shimmer.box);
                                    }
                                    final docs = snapshot.data?.docs;
                                    return Expanded(
                                      child: FriendsTile(
                                        title: docs?.length == 1
                                            ? 'Post'
                                            : 'Posts',
                                        count: docs?.length ?? 0,
                                      ),
                                    );
                                  }),
                              Expanded(child: SizedBox()),
                            ],
                          )
                        ],
                      )),
                      const SizedBox(width: Dimens.sizeLarge),
                    ],
                  );
                }),
            const SizedBox(height: Dimens.sizeLarge),
            StreamBuilder(
                stream: controller.users.snapshots(),
                builder: (context, snapshot) {
                  final user = controller.authServices.user.value!;
                  if (snapshot.hasError) return const SizedBox();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Row(children: [
                      const SizedBox(width: Dimens.sizeLarge),
                      Expanded(child: SizedBox(height: 35, child: Shimmer.box)),
                      const SizedBox(width: Dimens.sizeDefault),
                      Expanded(child: SizedBox(height: 35, child: Shimmer.box)),
                      const SizedBox(width: Dimens.sizeLarge),
                    ]);
                  }
                  final docs = snapshot.data?.docs.map((e) {
                    return UserDetails.fromJson(e.data());
                  });
                  final otherUser = docs!.firstWhere((e) => e.id == userId);
                  final myUser = docs.firstWhere((e) => e.id == user.id);

                  return Row(
                    children: [
                      const SizedBox(width: Dimens.sizeLarge),
                      Expanded(
                        child: LoadingButton(
                            onPressed: myUser.requests.contains(otherUser.id)
                                ? () => controller.acceptReq(otherUser.id)
                                : () => controller.sendReq(otherUser.id),
                            enable: !(otherUser.friends.contains(user.id) ||
                                otherUser.requests.contains(user.id)),
                            isLoading: false,
                            compact: true,
                            width: double.infinity,
                            border: Dimens.borderSmall,
                            child: Text(text(myUser, otherUser))),
                      ),
                      const SizedBox(width: Dimens.sizeDefault),
                      Expanded(
                        child: LoadingButton(
                            enable: otherUser.friends.contains(user.id),
                            onPressed: () => controller.toChat(otherUser),
                            isLoading: false,
                            compact: true,
                            width: double.infinity,
                            border: Dimens.borderSmall,
                            child: const Text(StringRes.sendMessage)),
                      ),
                      const SizedBox(width: Dimens.sizeLarge),
                    ],
                  );
                }),
            const SizedBox(height: Dimens.sizeLarge),
            const ListTile(
              minVerticalPadding: 0,
              visualDensity: VisualDensity.compact,
              leading: Icon(Icons.photo_library_outlined),
              title: Text(StringRes.posts),
            ),
            FutureBuilder(
                future: controller.posts
                    .where('author', isEqualTo: userId)
                    .orderBy('author')
                    .orderBy('date_time', descending: true)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const ToolTipWidget();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimens.sizeExtraSmall),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, _) {
                          return const MyCachedImage.loading();
                        });
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

                  return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(Dimens.sizeExtraSmall),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: posts?.length ?? 0,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => controller.toPost(context,
                              index: index, userId: posts[index].author),
                          splashColor: Colors.black38,
                          child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: MyCachedImage(posts![index].images.first)),
                        );
                      });
                })
          ],
        ));
  }

  String text(UserDetails user, UserDetails other) {
    if (other.friends.contains(user.id)) return StringRes.friends;
    if (other.requests.contains(user.id)) return StringRes.requested;
    if (user.requests.contains(other.id)) return StringRes.accept;

    return StringRes.sendRequest;
  }
}
