import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../model/models/post_model.dart';
import '../home_view/post_tile.dart';

class AllUserPosts extends StatefulWidget {
  const AllUserPosts({super.key});

  @override
  State<AllUserPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<AllUserPosts> {
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final postController = ScrollController();
  late int postIndex;
  late String userId;

  void reload() => setState(() {});

  @override
  void initState() {
    postIndex = Get.arguments[0];
    userId = Get.arguments[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.myPosts),
          titleTextStyle: Utils.defTitleStyle,
          centerTitle: false,
        ),
        padding: EdgeInsets.zero,
        child: FutureBuilder(
            future: posts.orderBy('date_time').get(),
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
              posts?.removeWhere((e) => e.author != userId);

              double height = 0;
              try {
                height = posts![postIndex].images.length > 1 ? 0.55 : 0.77;
              } catch (_) {}

              Future.delayed(const Duration(milliseconds: 100), () {
                postController
                    // ignore: use_build_context_synchronously
                    .jumpTo(postIndex * context.height * height);
              });

              return ListView.builder(
                  controller: postController,
                  itemCount: posts?.length ?? 0,
                  padding: EdgeInsets.only(bottom: context.height * .1),
                  itemBuilder: (context, index) {
                    final doc = snapshot.data?.docs.firstWhere(
                        (e) => e.data()['date_time'] == posts![index].dateTime);
                    return PostTile(
                      id: doc!.id,
                      post: posts![index],
                      reload: reload,
                    );
                  });
            }));
  }
}
