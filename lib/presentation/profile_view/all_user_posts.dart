import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import '../../data/models/post_model.dart';
import '../home_view/post_tile.dart';

class AllUserPosts extends StatefulWidget {
  const AllUserPosts({super.key});

  @override
  State<AllUserPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<AllUserPosts> {
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final postController = ScrollController();
  final user = Get.find<AuthServices>().user.value;
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
          title: user!.id == userId
              ? const Text(StringRes.myPosts)
              : FutureBuilder(
                  future: users.doc(userId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const ToolTipWidget();
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 100,
                        height: 20,
                        child: Shimmer.box,
                      );
                    }
                    final json = snapshot.data?.data();
                    final name = json!['display_name'].split(' ').first;
                    return Text('$name\'s Posts');
                  }),
          titleTextStyle: Utils.defTitleStyle,
          centerTitle: false,
        ),
        padding: EdgeInsets.zero,
        child: FutureBuilder(
            future: posts
                .where('author', isEqualTo: userId)
                .orderBy('author')
                .orderBy('date_time', descending: true)
                .get(),
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
