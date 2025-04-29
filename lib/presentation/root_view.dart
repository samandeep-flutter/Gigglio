import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:gigglio/presentation/home_view/home_screen.dart';
import 'package:gigglio/presentation/messages_view/messages_screen.dart';
import 'package:gigglio/presentation/profile_view/profile_screen.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/business_logic/root_controller.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return BaseWidget(
      padding: EdgeInsets.zero,
      color: scheme.background,
      resizeBottom: false,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          TabBarView(
            controller: controller.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              MessagesScreen(),
              ProfileScreen(),
            ],
          ),
          SafeArea(
              minimum: const EdgeInsets.only(bottom: Dimens.sizeDefault),
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: Dimens.sizeMidLarge),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimens.sizeExtraLarge)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.sizeExtraLarge),
                    child: _NavBar()),
              ))
        ],
      ),
    );
  }
}

class _NavBar extends StatefulWidget {
  @override
  State<_NavBar> createState() => __NavBarState();
}

class __NavBarState extends State<_NavBar> {
  RootController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BottomNavigationBar(
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      items: controller.tabList,
      currentIndex: controller.tabController.index,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.disabled,
      backgroundColor: scheme.surface,
      onTap: (value) {
        setState(() {
          controller.tabController.index = value;
        });
      },
    );
  }
}
