import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/notification_model.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/model/utils/utils.dart';
import 'package:gigglio/view/widgets/base_widget.dart';
import 'package:gigglio/view/widgets/shimmer_widget.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import '../../services/theme_services.dart';
import '../../view_models/controller/home_controller.dart';

class NotificationScreen extends GetView<HomeController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: const Text(StringRes.noti),
          titleTextStyle: Utils.defTitleStyle,
        ),
        child: FutureBuilder(
            future: controller.noti.get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const ToolTipWidget();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: Dimens.sizeLarge),
                  children: List.generate(3, (_) {
                    return const UserTileShimmer(
                      trailing: SizedBox(),
                      avatarRadius: 24,
                    );
                  }),
                );
              }

              final docs = snapshot.data?.docs;
              if (docs?.isEmpty ?? true) {
                return const ToolTipWidget(title: StringRes.noNoti);
              }

              controller.notiSeen = docs!.length;
              List<NotiModel> noti = docs.map((e) {
                return NotiModel.fromJson(e.data());
              }).toList();
              return ListView.builder(
                  itemCount: noti.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(noti[index].category.desc));
                  });
            }));
  }
}
