import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';

class MessagesController extends GetxController {
  final messages = FirebaseFirestore.instance.collection(FB.messages);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final AuthServices authServices = Get.find();

  RxList<UserDetails> allUsers = RxList();
  RxList<UserDetails> usersList = RxList();
  RxList<UserDetails> seachedUsers = RxList();

  final searchContr = TextEditingController();
  final newChatContr = TextEditingController();
  final searchFoucs = FocusNode();
  final newChatFocus = FocusNode();

  @override
  void onInit() {
    newChatContr.addListener(onUserSearch);
    super.onInit();
  }

  void gotoProfile(String id) => Get.toNamed(Routes.gotoProfile, arguments: id);

  Future<void> onUserSearch() async {
    if (newChatContr.text.isEmpty) {
      usersList.value = allUsers;
      return;
    }
    seachedUsers.value = allUsers.where((e) {
      return e.displayName.toLowerCase().contains(newChatContr.text);
    }).toList();
    usersList.value = seachedUsers;
    return;
  }

  void toNewChat() => Get.toNamed(Routes.newChat);

  void toChatScreen(UserDetails otherUser, {bool replace = false}) {
    if (replace) {
      Get.offNamed(Routes.chatScreen, arguments: otherUser);
      return;
    }
    Get.toNamed(Routes.chatScreen, arguments: otherUser);
  }
}
