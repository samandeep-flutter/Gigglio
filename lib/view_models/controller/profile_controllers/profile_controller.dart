import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import '../../routes/routes.dart';

class ProfileController extends GetxController {
  AuthServices authServices = Get.find();
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final users = FirebaseFirestore.instance.collection(FB.users);
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

  void toPost(BuildContext context, {required int index}) {
    Get.toNamed(Routes.myPosts, arguments: index);
  }

  void fromFriends(bool didPop, [result]) {
    friendContr.clear();
    allUsers.clear();
    searchedUsers.clear();
    friendsList.clear();
  }

  void sendRequest(String id) {
    final userId = authServices.user.value!.id;
    final doc = users.doc(id);
    doc.update({
      'requests': FieldValue.arrayUnion([userId])
    });
  }

  void acceptRequest(String id, {required int index}) async {
    final userId = authServices.user.value!.id;
    final otherUser = users.doc(id);
    final myUser = users.doc(userId);
    await otherUser.update({
      'friends': FieldValue.arrayUnion([userId]),
    });
    await myUser.update({
      'friends': FieldValue.arrayUnion([id]),
      'requests': FieldValue.arrayRemove([id]),
    });
    reqAccepted[index] = true;
  }
}
