import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/messages_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../../model/utils/app_constants.dart';
import '../../../services/auth_services.dart';

class ChatController extends GetxController {
  final messages = FirebaseFirestore.instance.collection(FB.messages);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final AuthServices authServices = Get.find();

  final messageContr = TextEditingController();
  final messageKey = GlobalKey<FormFieldState>();

  final scrollContr = ScrollController();
  RxBool isIdLoading = RxBool(false);

  late UserDetails otherUser;
  String chatId = '';

  @override
  void onInit() {
    otherUser = Get.arguments;
    _findDoc().then((id) {
      final user = authServices.user.value!;
      final chatId = id ?? '${user.id}:${otherUser.id}';
      if (id == null) {
        final message = MessagesModel(users: [
          UserData.newUser(user.id),
          UserData.newUser(otherUser.id),
        ]);
        messages.doc(chatId).set(message.toJson());
      }
      this.chatId = chatId;
      isIdLoading.value = false;
      scrollListener();
    });
    super.onInit();
  }

  @override
  void onReady() {
    scrollContr.addListener(scrollListener);
    super.onReady();
  }

  void scrollListener() async {
    final json = await messages.doc(chatId).get();
    final model = MessagesModel.fromJson(json.data()!);
    final user = authServices.user.value;

    try {
      final position = scrollContr.position;
      model.users.firstWhere((e) => e.id == user!.id)
        ..scrollAt = position.pixels
        ..seen = model.messages.length;
    } catch (_) {
      model.users.firstWhere((e) => e.id == user!.id).seen =
          model.messages.length;
    }

    messages.doc(chatId).set(model.toJson());
  }

  Future<String?> _findDoc() async {
    isIdLoading.value = true;
    final user = authServices.user.value!;
    final snapshot = await messages.get();
    var doc = snapshot.docs.firstWhereOrNull((e) {
      List<String> users = e.id.split(':');
      return users.contains(otherUser.id) && users.contains(user.id);
    });
    return doc?.id;
  }

  void sendMessage(MessagesModel? messages) async {
    if (messageContr.text.isEmpty || messages == null) return;
    final dateTime = DateTime.now().toJson();
    final position = scrollContr.position;

    double? scrollAt = position.pixels > 0 ? position.pixels : null;
    final newMessage = Messages(
      author: authServices.user.value!.id,
      dateTime: dateTime,
      text: messageContr.text,
      scrollAt: scrollAt,
      position: messages.messages.length + 1,
    );

    messages.messages.add(newMessage);
    this.messages.doc(chatId).set(messages.toJson());
    messageContr.clear();
  }
}
