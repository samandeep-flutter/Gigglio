import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/messages_model.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../../model/utils/app_constants.dart';
import '../../../services/auth_services.dart';
import '../../routes/routes.dart';

class ChatController extends GetxController {
  final messages = FirebaseFirestore.instance.collection(FB.messages);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final AuthServices authServices = Get.find();

  final messageContr = TextEditingController();
  final messageKey = GlobalKey<FormFieldState>();

  final scrollContr = ScrollController();
  RxBool isIdLoading = RxBool(false);
  bool isScrolled = false;

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
      readRecipts();
    });
    super.onInit();
  }

  @override
  void onReady() {
    scrollContr.addListener(readRecipts);
    super.onReady();
  }

  void gotoProfile(String id) => Get.toNamed(Routes.gotoProfile, arguments: id);

  void readRecipts() async {
    final json = await messages.doc(chatId).get();
    final model = MessagesModel.fromJson(json.data()!);
    final user = authServices.user.value;
    final index = model.users.indexWhere((e) => e.id == user!.id);

    try {
      final position = scrollContr.position;
      model.users[index]
        ..scrollAt = position.pixels
        ..seen = model.messages.length;
    } catch (_) {
      model.users[index].seen = model.messages.length;
    }
    messages.doc(chatId).update({
      'users': model.users.map((e) {
        return e.toJson();
      }).toList()
    });
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

  void sendMessage(MessagesModel? model) async {
    if (messageContr.text.isEmpty || model == null) return;
    final dateTime = DateTime.now().toJson();
    final position = scrollContr.position;

    double? scrollAt = position.pixels > 0 ? position.pixels : null;
    final newMessage = Messages(
      author: authServices.user.value!.id,
      dateTime: dateTime,
      text: messageContr.text,
      scrollAt: scrollAt,
      position: model.messages.length + 1,
    );
    messages.doc(chatId).update({
      'messages': FieldValue.arrayUnion([newMessage.toJson()]),
      'last_updated': dateTime,
    });
    messageContr.clear();
  }
}
