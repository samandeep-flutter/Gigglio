import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/models/messages_model.dart';
import 'package:gigglio/data/models/user_details.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../data/utils/app_constants.dart';
import '../../services/auth_services.dart';
import '../../config/routes/routes.dart';

class ChatController extends GetxController {
  final messages = FirebaseFirestore.instance.collection(FB.messages);
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final users = FirebaseFirestore.instance.collection(FB.users);
  final AuthServices authServices = Get.find();

  final messageContr = TextEditingController();
  final messageKey = GlobalKey<FormFieldState>();

  final scrollContr = ScrollController();
  RxBool isIdLoading = RxBool(false);
  bool isScrolled = false;

  late UserDetails otherUser;
  String? chatId;

  @override
  void onInit() {
    otherUser = Get.arguments;
    _findDoc().then((id) async {
      final user = authServices.user.value!;
      String? chatId = id;
      if (id == null) {
        final message = MessagesModel(
          users: [user.id, otherUser.id],
          userData: [
            UserData.newUser(user.id),
            UserData.newUser(otherUser.id),
          ],
        );
        final doc = await messages.add(message.toJson());
        chatId = doc.id;
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
  void gotoPost(String id) => Get.toNamed(Routes.gotoPost, arguments: id);

  Future<String?> _findDoc() async {
    isIdLoading.value = true;
    final user = authServices.user.value!;
    try {
      final snapshot =
          await messages.where('users', arrayContains: user.id).get();
      snapshot.docs.removeWhere((e) {
        return !(e.data()['users'] as List).contains(otherUser.id);
      });
      return snapshot.docs.first.id;
    } catch (_) {
      return null;
    }
  }

  void readRecipts() async {
    final json = await messages.doc(chatId).get();
    final model = MessagesModel.fromJson(json.data()!);
    final user = authServices.user.value;
    final index = model.userData.indexWhere((e) => e.id == user!.id);

    try {
      final position = scrollContr.position;
      model.userData[index]
        ..scrollAt = position.pixels
        ..seen = model.messages.length;
    } catch (_) {
      model.userData[index].seen = model.messages.length;
    }
    messages.doc(chatId).update({
      'user_data': model.userData.map((e) {
        return e.toJson();
      }).toList()
    });
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
