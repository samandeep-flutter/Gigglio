import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/profile_controllers/profile_controller.dart';

class GotoProfile extends GetView<ProfileController> {
  const GotoProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final id = Get.arguments;
    return BaseWidget(
        appBar: AppBar(backgroundColor: scheme.background),
        child: Column(
          children: [
            FutureBuilder(
                future: controller.users.doc(id).get(),
                builder: (context, snapshot) {
                  return const SizedBox.shrink();
                })
          ],
        ));
  }
}
