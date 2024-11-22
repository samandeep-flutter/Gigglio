import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/view_models/controller/profile_controllers/profile_controller.dart';
import '../../model/models/notification_model.dart';

class RootController extends GetxController with GetTickerProviderStateMixin {
  final AuthServices authServices = Get.find();
  final users = FirebaseFirestore.instance.collection(FB.users);
  final noti = FirebaseFirestore.instance.collection(FB.noti);

  late TabController tabController;

  final List<BottomNavigationBarItem> tabList = [
    const BottomNavigationBarItem(
      label: StringRes.home,
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
    ),
    const BottomNavigationBarItem(
      label: StringRes.messages,
      icon: Icon(Icons.message_outlined),
      activeIcon: Icon(Icons.message),
    ),
    const BottomNavigationBarItem(
      label: StringRes.profile,
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
    ),
  ];

  @override
  void onInit() {
    tabController = TabController(length: tabList.length, vsync: this);
    authServices.getUserDetails();
    // Get.find<HomeController>();
    super.onInit();
  }

  void sendRequest(String id) {
    final userId = authServices.user.value!.id;
    final doc = users.doc(id);
    doc.update({
      'requests': FieldValue.arrayUnion([userId])
    });
    final noti = NotiModel(
      from: userId,
      to: id,
      postId: null,
      dateTime: DateTime.now().toJson(),
      category: NotiCategory.request,
    );
    this.noti.add(noti.toJson());
  }

  void acceptRequest(String id, {int? index}) async {
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
    if (index != null) {
      Get.find<ProfileController>().reqAccepted[index] = true;
    }
  }
}
