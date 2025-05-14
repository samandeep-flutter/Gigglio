import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/notification_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/loading_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    final bloc = context.read<NotificationBloc>();
    bloc.add(NotificationInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.noti),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: false,
      ),
      padding: EdgeInsets.zero,
      child: BlocBuilder<NotificationBloc, NotificationState>(
          buildWhen: (pr, cr) => pr.loading != cr.loading,
          builder: (context, state) {
            if (state.loading) return const NotificationShimmer();

            if (state.notifications.isEmpty) {
              return const ToolTipWidget(title: StringRes.noNoti);
            }
            return ListView.builder(
                itemCount: state.notifications.length,
                padding: const EdgeInsets.only(top: Dimens.sizeDefault),
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimens.sizeExtraSmall),
                    child: ListTile(
                      leading: MyAvatar(item.from.image,
                          isAvatar: true, id: item.from.id),
                      horizontalTitleGap: Dimens.sizeSmall,
                      title: MyRichText(
                          style: TextStyle(
                              color: scheme.textColor,
                              fontSize: Dimens.fontDefault),
                          maxLines: 3,
                          children: [
                            TextSpan(
                                text: item.from.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const WidgetSpan(child: SizedBox(width: 4)),
                            TextSpan(text: item.category.desc)
                          ]),
                      trailing: _TrailingWidget(item),
                    ),
                  );
                });
          }),
    );
  }
}

class _TrailingWidget extends StatelessWidget {
  final NotiModel noti;
  const _TrailingWidget(this.noti);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificationBloc>();

    if (noti.category.isRequest) {
      return BlocBuilder<NotificationBloc, NotificationState>(
          buildWhen: (pr, cr) => pr.profile != cr.profile,
          builder: (context, state) {
            return LoadingButton(
                compact: true,
                defWidth: true,
                border: Dimens.borderSmall,
                enable: !state.profile!.friends.contains(noti.from.id),
                onPressed: () => bloc.add(NotiReqAccepted(noti.from.id)),
                child: Builder(builder: (context) {
                  if (state.profile!.friends.contains(noti.from.id)) {
                    return const Text(StringRes.accepted);
                  }
                  return const Text(StringRes.accept);
                }));
          });
    }
    return MyAvatar(
      noti.post?.images.first,
      borderRadius: Dimens.borderDefault,
      onTap: () {
        final post = noti.post?.id;
        context.pushNamed(AppRoutes.gotoPost, extra: post);
      },
    );
  }
}
