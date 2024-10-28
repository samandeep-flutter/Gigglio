import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/my_cached_image.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/home_controller.dart';
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
                  final json = snapshot.data!.docs[index].data();
                  final post = PostModel.fromJson(json);
                  return PostTile(post: post);
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
        _ImageViewer(post: post)
      ],
    );
  }
}

class _ImageViewer extends StatefulWidget {
  final PostModel post;
  const _ImageViewer({required this.post});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  final pageContr = PageController();
  late PostModel post;
  int current = 0;

  @override
  void initState() {
    post = widget.post;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: context.height * .35),
          child: PageView.builder(
              controller: pageContr,
              onPageChanged: (value) => setState(() {
                    current = value;
                  }),
              itemCount: post.images.length,
              itemBuilder: (context, index) {
                return MyCachedImage(
                  width: context.width,
                  post.images[index],
                  fit: BoxFit.fitWidth,
                );
              }),
        ),
        const SizedBox(height: Dimens.sizeMedSmall),
        if (post.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(post.images.length, (index) {
              return PhotoPager(
                current: current == index,
                onTap: () {
                  pageContr.animateToPage(index,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut);
                },
              );
            }),
          ),
      ],
    );
  }
}
