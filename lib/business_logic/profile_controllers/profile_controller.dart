import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import '../../config/routes/routes.dart';
import '../root_controller.dart';

class ProfileController extends GetxController
    with GetTickerProviderStateMixin {
  final AuthServices authServices = Get.find();
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final storage = FirebaseStorage.instance;
  final postController = ScrollController();

  final friendContr = TextEditingController();
  RxList<UserDetails> allUsers = RxList();
  RxList<UserDetails> friendsList = RxList();
  RxList<UserDetails> searchedUsers = RxList();
  RxList<bool> reqAccepted = RxList();

  void toSettings() => Get.toNamed(Routes.settings);
  void toFriends() => Get.toNamed(Routes.addFriends);
  void toViewRequests() => Get.toNamed(Routes.viewRequests);
  void toEditProfile() => Get.toNamed(Routes.editProfile);
  void gotoProfile(String id) => Get.toNamed(Routes.gotoProfile, arguments: id);
  void sendReq(String id) => Get.find<RootController>().sendRequest(id);
  void acceptReq(String id, {int? index}) {
    Get.find<RootController>().acceptRequest(id, index: index);
  }

  @override
  void onReady() {
    friendContr.addListener(onSearch);
    super.onReady();
  }

  onSearch() {
    if (friendContr.text.isEmpty) return searchedUsers.value = friendsList;
    searchedUsers.value = allUsers.where((e) {
      return e.email.split('@').first.contains(friendContr.text);
    }).toList();
  }

  void toPost(BuildContext context,
      {required int index, required String userId}) {
    Get.toNamed(Routes.allUserPosts, arguments: [index, userId]);
  }

  void fromFriends(bool didPop, [result]) {
    friendContr.clear();
    allUsers.clear();
    searchedUsers.clear();
    friendsList.clear();
  }
}
