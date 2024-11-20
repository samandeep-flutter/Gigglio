import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../model/models/post_model.dart';
import '../../view_models/controller/profile_controllers/profile_controller.dart';
import '../home_view/post_tile.dart';

class MyPosts extends GetView<ProfileController> {
  const MyPosts({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final user = controller.authServices.user.value;
    final int postIndex = Get.arguments;
    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.myPosts),
          titleTextStyle: Utils.defTitleStyle,
          centerTitle: false,
        ),
        padding: EdgeInsets.zero,
        child: FutureBuilder(
            future: controller.posts.where('author', isEqualTo: user!.id).get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const ToolTipWidget();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(2, (_) => const PostTileShimmer()));
              }
              final posts = snapshot.data?.docs.map((e) {
                return PostModel.fromJson(e.data());
              }).toList();

              final height = posts![postIndex].images.length > 1 ? 0.55 : 0.77;
              Future.delayed(const Duration(milliseconds: 100), () {
                controller.postController
                    // ignore: use_build_context_synchronously
                    .jumpTo(postIndex * context.height * height);
              });

              return ListView.builder(
                  controller: controller.postController,
                  itemCount: posts.length,
                  padding: EdgeInsets.only(bottom: context.height * .1),
                  itemBuilder: (context, index) {
                    final doc = snapshot.data?.docs[index].id;
                    final post = posts[index];
                    bool last = posts.length == index + 1;
                    return PostTile(id: doc!, post: post, last: last);
                  });
            }));
  }
}
