import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/post_model.dart';
import '../../data/utils/app_constants.dart';
import '../../services/auth_services.dart';

class AddPostController extends GetxController {
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final storage = FirebaseStorage.instance.ref();
  final AuthServices authServices = Get.find();

  final captionContr = TextEditingController();
  RxList<File> postImages = RxList();
  RxBool isPostLoading = RxBool(false);
  RxBool isImageLoading = RxBool(false);

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
      logPrint(e, 'ImagePicker');
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
      final ref = storage.child(AppConstants.postImage('$dateTime/$path'));
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
    if (postImages.isEmpty) {
      showToast('Kindly add photos to continue');
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
      logPrint(e, 'AddPost');
    }
  }
}
