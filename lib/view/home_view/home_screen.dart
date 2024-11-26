import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controllers/home_controller.dart';
import 'post_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController controller = Get.find();

  Future<void> reload() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final user = controller.authServices.user.value;
    if (user == null) return const SizedBox.shrink();

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        automaticallyImplyLeading: false,
        title: TextButton.icon(
          onPressed: controller.toPost,
          label: const Text(StringRes.addPost),
          icon: const Icon(Icons.add),
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: controller.toNotifications,
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(Icons.favorite_border_rounded),
                  StreamBuilder(
                      stream: controller.noti
                          .where('to', isEqualTo: user.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        final docs = snapshot.data?.docs;
                        return StreamBuilder(
                            stream: controller.users.doc(user.id).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              }
                              final json = snapshot.data?.data();
                              if ((docs?.length ?? 0) >
                                  json!['noti_seen_count']) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: scheme.background,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: CircleAvatar(
                                    radius: Dimens.sizeExtraSmall,
                                    backgroundColor: scheme.primary,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            });
                      })
                ],
              )),
          const SizedBox(width: Dimens.sizeDefault),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: reload,
        child: FutureBuilder(
            future: controller.posts
                .where('author', isNotEqualTo: user.id)
                .orderBy('author')
                .orderBy('date_time', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return NoData(reload);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(2, (_) => const PostTileShimmer()));
              }
              final posts = snapshot.data?.docs.map((e) {
                return PostModel.fromJson(e.data());
              }).toList();

              return ListView.builder(
                  itemCount: posts?.length ?? 0,
                  padding: EdgeInsets.only(bottom: context.height * .1),
                  itemBuilder: (context, index) {
                    final post = posts![index];
                    final doc = snapshot.data?.docs[index];
                    bool last = posts.length == index + 1;

                    return PostTile(
                      id: doc!.id,
                      post: post,
                      last: last,
                      reload: reload,
                    );
                  });
            }),
      ),
    );
  }
}

class NoData extends GetView<HomeController> {
  final VoidCallback onReload;
  const NoData(this.onReload, {super.key, required});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: context.height * .2,
          width: double.infinity,
        ),
        Text(
          StringRes.errorUnknown,
          style: TextStyle(color: scheme.textColorLight),
        ),
        TextButton.icon(
          onPressed: onReload,
          label: const Text(StringRes.refresh),
          icon: const Icon(Icons.refresh_outlined),
        )
      ],
    );
  }
}
