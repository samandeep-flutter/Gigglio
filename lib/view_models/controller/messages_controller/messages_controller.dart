import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
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
    searchContr.addListener(onSearch);
    newChatContr.addListener(onUserSearch);
    super.onInit();
  }

  Future<void> onSearch() async {
    const duration = Duration(milliseconds: 800);
    EasyDebounce.debounce(AppConstants.messageSearchKey, duration, () {
      // searchFoucs.unfocus();
    });
  }

  Future<void> onUserSearch() async {
    const duration = Duration(milliseconds: 500);
    EasyDebounce.debounce(AppConstants.usersSearchKey, duration, () {
      if (newChatContr.text.isNotEmpty) {
        seachedUsers.value = allUsers.where((e) {
          return e.displayName.toLowerCase().contains(newChatContr.text);
        }).toList();
        usersList.value = seachedUsers;
        return;
      }
      usersList.value = allUsers;
    });
  }

  void onClear() async {
    searchContr.clear();
    searchFoucs.unfocus();
  }

  void newChatClear() async {
    newChatContr.clear();
    newChatFocus.unfocus();
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
