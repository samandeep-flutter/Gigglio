import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view_models/controller/profile_controllers/profile_controller.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import '../../../model/models/notification_model.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  AuthServices authServices = Get.find();
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final noti = FirebaseFirestore.instance.collection(FB.noti);

  final commentContr = TextEditingController();
  final commentKey = GlobalKey<FormFieldState>();

  RxInt notiSeen = RxInt(0);

  void toNotifications() => Get.toNamed(Routes.notifications);
  void toPost() => Get.toNamed(Routes.addPost);

  void likePost(String id, {required PostModel post}) async {
    final user = authServices.user.value!;
    posts.doc(id).update({
      'likes': post.likes.contains(user.id)
          ? FieldValue.arrayRemove([user.id])
          : FieldValue.arrayUnion([user.id]),
    });
  }

  void gotoProfile(String id) => Get.toNamed(Routes.gotoProfile, arguments: id);
  void addFriend(String id) => Get.find<ProfileController>().sendRequest(id);
  void unfriend(String id) {}
  void deletePost(String doc, {required String dateTime}) {}

  void postComment(String doc, {required UserDetails postAuthor}) async {
    if (!(commentKey.currentState?.validate() ?? false)) return;
    if (commentContr.text.isEmpty) return;
    final user = authServices.user.value!;
    final comment = CommentModel(
        author: user.id,
        title: commentContr.text,
        dateTime: DateTime.now().toJson());

    posts.doc(doc).update({
      'comments': FieldValue.arrayUnion([comment.toJson()])
    });
    commentKey.currentState?.reset();
    commentContr.clear();
    FocusManager.instance.primaryFocus?.unfocus();

    if (postAuthor.friends.contains(user.id)) {
      final noti = NotiModel(
        from: user.id,
        to: postAuthor.id,
        postId: doc,
        category: NotiCategory.comment,
      );
      this.noti.add(noti.toJson());
    }
  }

  void sharePost(String id) {
    //TODO: develop share mechanism.

    // Get.toNamed(Routes.gotoPost, arguments: id);
  }
}
