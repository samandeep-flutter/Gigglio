import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view_models/controller/home_controllers/home_controller.dart';

class RootController extends GetxController with GetTickerProviderStateMixin {
  AuthServices authServices = Get.find();
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
    Get.find<HomeController>();
    super.onInit();
  }
}
