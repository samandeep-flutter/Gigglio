import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/models/notification_model.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  AuthServices authServices = Get.find();
  final fbFire = FirebaseFirestore.instance;

  final storage = FirebaseStorage.instance.ref();
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final noti = FirebaseFirestore.instance.collection(FB.noti);

  final captionContr = TextEditingController();
  final commentContr = TextEditingController();
  final commentKey = GlobalKey<FormFieldState>();

  RxList<File> postImages = RxList();
  RxBool isPostLoading = RxBool(false);
  RxBool isImageLoading = RxBool(false);
  int notiSeen = 0;

  void toNotifications() => Get.toNamed(Routes.notifications);

  void toPost() => Get.toNamed(Routes.addPost);

  void fromPost(bool didPop, [result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    postImages.clear();
    captionContr.clear();
  }

  void pickImages() async {
    final picker = ImagePicker();
    isImageLoading.value = true;
    try {
      List<XFile> images = await picker.pickMultiImage(
          imageQuality: 20, requestFullMetadata: false);
      if (images.isEmpty) return;
      postImages.addAll(images.map((e) => File(e.path)));
    } catch (e) {
      logPrint('ImagePicker: $e');
    }
    isImageLoading.value = false;
  }

  Future<List<String>> _uploadImages(
    List<File> images, {
    required String dateTime,
  }) async {
    List<String> list = [];
    for (var image in postImages) {
      final path = image.path.split('/').last;
      final ref = storage.child(AppConstants.postImage(path, time: dateTime));
      await ref.putFile(image);
      list.add(await ref.getDownloadURL());
    }
    return list;
  }

  void addPost() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (postImages.isEmpty && captionContr.text.isEmpty) {
      showToast('Post discarded');
      Get.back();
      return;
    }
    isPostLoading.value = true;
    final now = DateTime.now().toJson();
    try {
      List<String> images = await _uploadImages(postImages, dateTime: now);
      var post = PostModel.add(
        author: authServices.user.value!.id,
        desc: captionContr.text,
        images: images,
        dateTime: now,
      );
      Get.back();
      showToast('Posting...');
      posts.add(post.toJson());
      isPostLoading.value = false;
    } catch (e) {
      isPostLoading.value = false;
      logPrint('AddPost: $e');
    }
  }

  void likePost(String id, {required PostModel post}) async {
    final user = authServices.user.value!;
    posts.doc(id).update({
      'likes': post.likes.contains(user.id)
          ? FieldValue.arrayRemove([user.id])
          : FieldValue.arrayUnion([user.id]),
    });
  }

  addFriend(String id) {}
  unfriend(String id) {}
  deletePost(String doc, {required String dateTime}) {}

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

  void sharePost(String id) => showToast('comming soon');
}
