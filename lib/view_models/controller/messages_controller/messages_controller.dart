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

  // RxList<MessagesModel> allMessages = RxList();
  // RxList<MessagesModel> messageList = RxList();
  // RxList<MessagesModel> searchedMessages = RxList();

  final searchContr = TextEditingController();
  final newChatContr = TextEditingController();
  final searchFoucs = FocusNode();
  final newChatFocus = FocusNode();

  @override
  void onInit() {
    // searchContr.addListener(onSearch);
    newChatContr.addListener(onUserSearch);
    super.onInit();
  }

  // Future<void> onSearch() async {
  //   const duration = Duration(milliseconds: 500);
  //   EasyDebounce.debounce(AppConstants.messageSearchKey, duration, () {
  //     if (searchContr.text.isNotEmpty) {
  //       searchedMessages.value = allMessages.where((e) {
  //         return e.displayName.toLowerCase().contains(searchContr.text);
  //       }).toList();
  //       messageList.value = searchedMessages;
  //       return;
  //     }
  //     messageList.value = allMessages;
  //   });
  // }

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
