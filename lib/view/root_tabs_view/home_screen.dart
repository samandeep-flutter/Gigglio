import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/root_tabs_controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseWidget(
      child: Center(
        child: Text('Home'),
      ),
    );
  }
}
