import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthServices authServices = Get.find();
    return BaseWidget(
      child: Center(
        child: ElevatedButton.icon(
          onPressed: authServices.logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ),
    );
  }
}
