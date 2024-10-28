import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/post_model.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  AuthServices authServices = Get.find();

  final storage = FirebaseStorage.instance.ref();
  final posts = FirebaseFirestore.instance.collection(FB.post);

  RxList<File> postImages = RxList();
  RxBool isPostLoading = RxBool(false);
  RxBool isImageLoading = RxBool(false);

  final captionContr = TextEditingController();

  void toNotifications() => Get.toNamed(Routes.notifications);

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

  Future<void> reload() async {}

  void addPost() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (postImages.isEmpty && captionContr.text.isEmpty) {
      showToast('Post discarded');
      Get.back();
      return;
    }
    isPostLoading.value = true;
    final now = Utils.dateTime(DateTime.now());
    try {
      List<String> images = await _uploadImages(postImages, dateTime: now);
      var post = PostModel.add(
        author: authServices.user.value!,
        desc: captionContr.text,
        images: images,
        dateTime: now,
      );
      await posts.add(post.toJson());
      isPostLoading.value = false;
      showToast('Posting...');
      Get.back();
    } catch (e) {
      isPostLoading.value = false;
      logPrint('AddPost: $e');
    }
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

  void toPost() => Get.toNamed(Routes.addPost);

  void fromPost() {
    FocusManager.instance.primaryFocus?.unfocus();
    postImages.clear();
    captionContr.clear();
  }
}
