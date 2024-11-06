import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import '../../../model/utils/app_constants.dart';
import '../../../services/auth_services.dart';

class ChatController extends GetxController {
  final messages = FirebaseFirestore.instance.collection(FB.messages);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final AuthServices authServices = Get.find();

  final messageContr = TextEditingController();
  final messageKey = GlobalKey<FormFieldState>();

  late UserDetails otherUser;
  String chatId = '';

  @override
  void onInit() {
    otherUser = Get.arguments;
    _findDoc();
    super.onInit();
  }

  Future<void> _findDoc() async {
    final user = authServices.user.value!;
    final snapshot = await messages.get();
    var doc = snapshot.docs.firstWhereOrNull((e) {
      List<String> users = e.id.split(':');
      return users.contains(otherUser.id) && users.contains(user.id);
    });

    chatId = doc?.id ?? '${user.id}:${otherUser.id}';
  }

  void sendMessage() {
    if (messageContr.text.isEmpty) return;
  }
}
