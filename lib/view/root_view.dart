import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/view/root_tabs_view/home_screen.dart';
import 'package:gigglio/view/root_tabs_view/messages_screen.dart';
import 'package:gigglio/view/root_tabs_view/profile_screen.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view_models/controller/root_controller.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  RootController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return BaseWidget(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          TabBarView(
            controller: controller.tabController,
            children: const [
              HomeScreen(),
              MessagesScreen(),
              ProfileScreen(),
            ],
          ),
          SafeArea(
              child: Card(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.sizeDefault),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.sizeExtraLarge)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.sizeExtraLarge),
              child: BottomNavigationBar(
                landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
                items: controller.tabList,
                currentIndex: controller.tabController.index,
                selectedItemColor: scheme.primary,
                unselectedItemColor: scheme.disabled,
                onTap: (index) {
                  setState(() {
                    controller.tabController.index = index;
                  });
                },
              ),
            ),
          )),
        ],
      ),
    );
  }
}
