import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  AuthServices authServices = Get.find();
  final fbFire = FirebaseFirestore.instance;

  final storage = FirebaseStorage.instance.ref();
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final users = FirebaseFirestore.instance.collection(FB.users);

  final captionContr = TextEditingController();
  final commentContr = TextEditingController();
  final commentKey = GlobalKey<FormFieldState>();

  RxList<File> postImages = RxList();
  RxBool isPostLoading = RxBool(false);
  RxBool isImageLoading = RxBool(false);
  RxBool isCommentsLoading = RxBool(false);

  void toNotifications() => Get.toNamed(Routes.notifications);
  void toPost() => Get.toNamed(Routes.addPost);

  void fromPost() {
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
    final now = DateTime.now().toJson;
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

  void likePost(String id, {required PostModel post}) {
    bool check = post.likes.contains(authServices.user.value!.id);
    if (check) post.likes.remove(authServices.user.value!.id);
    post.likes.addIf(!check, authServices.user.value!.id);
    PostModel modified = post.copyWith(likes: post.likes);
    posts.doc(id).set(modified.toJson());
  }

  void postComment(String id, {required PostModel post}) {
    if (!(commentKey.currentState?.validate() ?? false)) return;
    if (commentContr.text.isEmpty) return;
    final comment = CommentModel(
        author: authServices.user.value!.id,
        title: commentContr.text,
        dateTime: DateTime.now().toJson);
    post.comments.add(comment);
    posts.doc(id).set(post.toJson());
    commentKey.currentState?.reset();
    commentContr.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void sharePost(String id) => showToast('comming soon');
}
