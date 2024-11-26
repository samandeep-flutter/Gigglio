import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view_models/controller/root_controller.dart';
import '../../routes/routes.dart';

class GotoProfileController extends GetxController {
  final users = FirebaseFirestore.instance.collection(FB.users);
  final posts = FirebaseFirestore.instance.collection(FB.post);
  final AuthServices authServices = Get.find();
  final RootController _rootController = Get.find();
  late String userId;

  @override
  void onInit() {
    userId = Get.arguments;
    super.onInit();
  }

  void toChat(UserDetails user) {
    Get.toNamed(Routes.chatScreen, arguments: user);
  }

  void toPost(BuildContext context,
      {required int index, required String userId}) {
    Get.toNamed(Routes.allUserPosts, arguments: [index, userId]);
  }

  void sendReq(String id) => _rootController.sendRequest(id);
  void acceptReq(String id) => _rootController.acceptRequest(id);
}
