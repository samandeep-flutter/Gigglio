import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/models/post_model.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/presentation/home_view/post_tile.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';

class GotoPost extends StatefulWidget {
  const GotoPost({super.key});

  @override
  State<GotoPost> createState() => _GotoPostState();
}

class _GotoPostState extends State<GotoPost> {
  final posts = FirebaseFirestore.instance.collection(FB.post);

  void reload() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final doc = Get.arguments;
    return BaseWidget(
        padding: EdgeInsets.zero,
        appBar: AppBar(
            centerTitle: false,
            // title: const Text(AppConstants.appName),
            backgroundColor: scheme.background,
            titleTextStyle: Utils.defTitleStyle.copyWith(
              fontWeight: FontWeight.bold,
            )),
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: posts.doc(doc).get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const ToolTipWidget();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const PostTileShimmer();
                }
                final json = snapshot.data?.data();
                final post = PostModel.fromJson(json!);
                return PostTile(
                  id: doc,
                  post: post,
                  last: false,
                  reload: reload,
                );
              }),
        ));
  }
}
