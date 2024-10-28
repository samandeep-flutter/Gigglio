import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controller/home_controller.dart';

class Notifications extends GetView<HomeController> {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
      appBar: AppBar(backgroundColor: scheme.background),
      child: const SizedBox(),
    );
  }
}
