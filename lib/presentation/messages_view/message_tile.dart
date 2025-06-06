import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/business_logic/messages_bloc/chat_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';

class MessageTile extends StatelessWidget {
  final Messages message;
  final bool? seen;
  final bool sameUserAbove;
  final bool sameUserBelow;

  const MessageTile(
    this.message, {
    super.key,
    required this.seen,
    this.sameUserAbove = false,
    this.sameUserBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    final scheme = context.scheme;
    final me = message.author == bloc.userId;

    if (message.post != null) {
      return Row(
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          const SizedBox(width: Dimens.sizeDefault),
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.borderDefault),
            child: ColoredBox(
              color: scheme.background,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimens.sizeSmall),
                  Row(
                    children: [
                      const SizedBox(width: Dimens.sizeSmall),
                      MyAvatar(
                        message.post?.author.image,
                        isAvatar: true,
                        id: message.post?.author.id,
                        avatarRadius: 14,
                      ),
                      const SizedBox(width: Dimens.sizeSmall),
                      Text(
                        message.post?.author.displayName ?? '',
                        style: TextStyle(
                            fontSize: Dimens.fontDefault,
                            color: scheme.textColorLight),
                      ),
                      const SizedBox(width: Dimens.sizeSmall),
                    ],
                  ),
                  const SizedBox(height: Dimens.sizeExtraSmall),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      MyAvatar(
                        onTap: () => gotoPost(context, id: message.post?.id),
                        padding: EdgeInsets.zero,
                        message.post?.images.first,
                        width: 200,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(Dimens.sizeSmall),
                        child: Row(
                          children: [
                            Text(
                              message.dateTime.formatTime,
                              style: TextStyle(
                                  color: scheme.background,
                                  fontSize: Dimens.fontMed),
                            ),
                            if (me) ...[
                              Text('\t\t'),
                              Icon(
                                Icons.done_all,
                                color: seen ?? false
                                    ? Colors.blue
                                    : scheme.backgroundDark,
                                size: Dimens.sizeDefault,
                              ),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Dimens.sizeDefault),
        ],
      );
    }

    return Row(
      mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        const SizedBox(width: Dimens.sizeDefault),
        Flexible(
          child: Container(
            margin: _margin(me),
            decoration: BoxDecoration(
                color: me ? scheme.primaryContainer : scheme.surface,
                borderRadius: _borderRadius(me)),
            padding: const EdgeInsets.only(
              top: Dimens.sizeSmall,
              left: Dimens.sizeSmall,
              right: Dimens.sizeSmall,
            ),
            child: SelectableText.rich(
              TextSpan(
                style: TextStyle(color: scheme.textColor),
                children: [
                  TextSpan(text: message.text ?? ''),
                  WidgetSpan(child: SizedBox(width: Dimens.sizeSmall)),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: Padding(
                          padding: EdgeInsets.only(top: Dimens.sizeMedSmall),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                message.dateTime.formatTime,
                                style: TextStyle(
                                    color: scheme.textColorLight,
                                    fontSize: Dimens.fontMed),
                              ),
                              if (me) ...[
                                SizedBox(width: Dimens.sizeExtraSmall),
                                Icon(
                                  Icons.done_all,
                                  color: seen ?? false
                                      ? Colors.blue
                                      : scheme.disabled,
                                  size: Dimens.sizeDefault,
                                )
                              ],
                            ],
                          )))
                ],
              ),
              textWidthBasis: TextWidthBasis.longestLine,
            ),
          ),
        ),
        const SizedBox(width: Dimens.sizeDefault),
      ],
    );
  }

  void gotoPost(BuildContext context, {required String? id}) {
    context.pushNamed(AppRoutes.gotoProfile, extra: id);
  }

  EdgeInsets _margin(bool me) {
    return EdgeInsets.only(
        bottom: sameUserBelow ? Dimens.sizeExtraSmall : Dimens.sizeSmall,
        left: me ? Dimens.sizeLarge : Dimens.zero,
        right: me ? Dimens.zero : Dimens.sizeLarge);
  }

  BorderRadius _borderRadius(bool me) {
    final border = Radius.circular(Dimens.borderSmall);
    return BorderRadius.only(
        topLeft: me || !sameUserAbove ? border : Radius.zero,
        topRight: me && sameUserAbove ? Radius.zero : border,
        bottomLeft: me || !sameUserBelow ? border : Radius.zero,
        bottomRight: me && sameUserBelow ? Radius.zero : border);
  }
}
