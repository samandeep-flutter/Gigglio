import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view_models/controller/home_controller/home_controller.dart';
import '../../services/theme_services.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        automaticallyImplyLeading: false,
        leading: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Builder(builder: (context) {
              return TextButton.icon(
                onPressed: controller.toPost,
                label: const Text(StringRes.addPost),
                icon: const Icon(Icons.add),
              );
            })),
        leadingWidth: 150,
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: controller.toNotifications,
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(Icons.favorite_border_rounded),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.background,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: Dimens.sizeExtraSmall,
                      backgroundColor: scheme.primary,
                    ),
                  )
                ],
              )),
          const SizedBox(width: Dimens.sizeDefault),
        ],
      ),
      child: StreamBuilder(
          stream: controller.posts.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const NoData();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: context.height * .1,
                    width: double.infinity,
                  ),
                  SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(color: scheme.primary),
                  )
                ],
              );
            }

            return ListView.builder(
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (context, index) {
                  final data =
                      PostModel.fromJson(snapshot.data!.docs[index].data());
                  return PostTile(post: data);
                });
          }),
    );
  }
}

class NoData extends GetView<HomeController> {
  const NoData({super.key});

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
          onPressed: controller.reload,
          label: const Text(StringRes.refresh),
          icon: const Icon(Icons.refresh_outlined),
        )
      ],
    );
  }
}

class PostTile extends GetView<HomeController> {
  final PostModel post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // final scheme = ThemeServices.of(context);

    return Column(
      children: [
        ListTile(
          leading: MyCachedImage(
            post.author.image,
            isAvatar: true,
          ),
          title: Text(post.author.displayName),
          subtitle: Text(post.author.email),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: context.height * .3),
          child: PageView.builder(
              controller: controller.pageContr,
              itemCount: post.images.length,
              itemBuilder: (context, index) {
                return MyCachedImage(
                  width: context.width,
                  post.images[index],
                  fit: BoxFit.fitWidth,
                );
              }),
        )
      ],
    );
  }
}
