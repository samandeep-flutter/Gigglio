import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/home_view/post_tile.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/controller/home_controllers/home_controller.dart';

class GotoPost extends GetView<HomeController> {
  const GotoPost({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final doc = Get.arguments;
    return BaseWidget(
        padding: EdgeInsets.zero,
        appBar: AppBar(
            centerTitle: false,
            title: const Text(AppConstants.appName),
            backgroundColor: scheme.background,
            titleTextStyle: Utils.defTitleStyle.copyWith(
              fontWeight: FontWeight.bold,
            )),
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: controller.posts.doc(doc).get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const ToolTipWidget();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const PostTileShimmer();
                }
                final json = snapshot.data?.data();
                final post = PostModel.fromJson(json!);
                return PostTile(id: doc, post: post, last: false);
              }),
        ));
  }
}
