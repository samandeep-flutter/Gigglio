import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/models/messages_model.dart';
import 'package:gigglio/data/models/post_model.dart';
import 'package:gigglio/data/models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/business_logic/root_controller.dart';
import 'package:gigglio/config/routes/routes.dart';
import '../../data/models/notification_model.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final AuthServices authServices = Get.find();
  final RootController _rootController = Get.find();
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final _messages = FirebaseFirestore.instance.collection(FB.messages);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final noti = FirebaseFirestore.instance.collection(FB.noti);
  final storage = FirebaseStorage.instance;

  final commentContr = TextEditingController();
  final commentKey = GlobalKey<FormFieldState>();
  final RxList<String> shareSel = RxList();
  final RxBool shareLoading = RxBool(false);

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
  void gotoPost(String id) => Get.toNamed(Routes.gotoPost, arguments: id);
  void sendReq(String id) => _rootController.sendRequest(id);
  void acceptReq(String id) => _rootController.acceptRequest(id);
  void unfriend(String id) {}

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
        dateTime: DateTime.now().toJson(),
        category: NotiCategory.comment,
      );
      this.noti.add(noti.toJson());
    }
  }

  void sharePost(String postId) async {
    final userId = authServices.user.value!.id;
    shareLoading.value = true;
    final ref = await _messages.where('users', arrayContains: userId).get();
    final List docs = [];
    for (var e in ref.docs) {
      final users = e.data()['users'] as List;
      users.removeWhere((e) => e == userId);
      docs.addIf(shareSel.contains(users.first), e.id);
    }
    for (var id in docs) {
      final doc = _messages.doc(id);
      await doc.get().then((e) {
        final text = '${AppConstants.appUrl}/$postId';
        final position = (e.data()!['messages'] as List).length;
        final message = Messages(
            author: userId,
            dateTime: DateTime.now().toJson(),
            text: text,
            scrollAt: null,
            position: position + 1);
        doc.update({
          'messages': FieldValue.arrayUnion([message.toJson()])
        });
      });
    }
    shareLoading.value = false;
    Get.back();
  }
}
