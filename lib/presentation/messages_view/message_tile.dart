import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/business_logic/messages_bloc/chat_bloc.dart';
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

    if (message.post?.isNotEmpty ?? false) {
      return Row(
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          const SizedBox(width: Dimens.sizeDefault),
          // FutureBuilder(
          //     future: controller.posts.doc(doc).get(),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasError) return const SizedBox();

          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return MyCachedImage.loading(
          //             borderRadius: BorderRadius.circular(Dimens.borderDefault),
          //             height: 150,
          //             width: 150);
          //       }
          //       final json = snapshot.data?.data();
          //       final post = PostModel.fromJson(json!);
          //       return Container(
          //         width: 200,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(Dimens.borderDefault),
          //           color: Colors.white,
          //         ),
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           crossAxisAlignment: CrossAxisAlignment.end,
          //           children: [
          //             const SizedBox(height: Dimens.sizeSmall),
          //             FutureBuilder(
          //                 future: controller.users.doc(post.author).get(),
          //                 builder: (context, snapshot) {
          //                   if (snapshot.hasError) {
          //                     return const ToolTipWidget(
          //                       margin: EdgeInsets.zero,
          //                       title: StringRes.somethingWrong,
          //                     );
          //                   }
          //                   if (snapshot.connectionState ==
          //                       ConnectionState.waiting) {
          //                     return Row(children: [
          //                       const MyCachedImage.loading(
          //                         isAvatar: true,
          //                         avatarRadius: 16,
          //                       ),
          //                       const SizedBox(width: 4),
          //                       SizedBox(
          //                         width: 100,
          //                         height: 20,
          //                         child: Shimmer.box,
          //                       ),
          //                     ]);
          //                   }
          //                   final json = snapshot.data?.data();
          //                   final user = UserDetails.fromJson(json!);
          //                   return Row(
          //                     children: [
          //                       const SizedBox(width: Dimens.sizeSmall),
          //                       MyAvatar(
          //                         user.image,
          //                         isAvatar: true,
          //                         id: user.id,
          //                         avatarRadius: 14,
          //                       ),
          //                       const SizedBox(width: Dimens.sizeSmall),
          //                       Text(
          //                         user.displayName,
          //                         style: TextStyle(
          //                             fontSize: Dimens.fontDefault,
          //                             color: scheme.textColorLight),
          //                       ),
          //                       const SizedBox(width: Dimens.sizeSmall),
          //                     ],
          //                   );
          //                 }),
          //             const SizedBox(height: Dimens.sizeExtraSmall),
          //             MyAvatar(
          //               onTap: () => controller.gotoPost(doc),
          //               padding: EdgeInsets.zero,
          //               post.images.first,
          //               height: 200,
          //               fit: BoxFit.fitWidth,
          //             ),
          //             Padding(
          //                 padding: const EdgeInsets.all(Dimens.sizeSmall),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.end,
          //                   children: [
          //                     Text(
          //                       post.desc ?? '',
          //                       maxLines: 1,
          //                       overflow: TextOverflow.ellipsis,
          //                     ),
          //                     const SizedBox(height: Dimens.sizeExtraSmall),
          //                     Row(
          //                       mainAxisSize: MainAxisSize.min,
          //                       children: [
          //                         Text(
          //                           message.dateTime.formatTime,
          //                           style: TextStyle(
          //                               color: scheme.textColorLight,
          //                               fontSize: Dimens.fontMed),
          //                         ),
          //                         if (message.author == user.id) ...[
          //                           const SizedBox(
          //                               width: Dimens.sizeExtraSmall),
          //                           Icon(
          //                             Icons.check_rounded,
          //                             color: isScrolled
          //                                 ? Colors.blue
          //                                 : scheme.disabled.withOpacity(.7),
          //                             size: Dimens.sizeDefault,
          //                           )
          //                         ]
          //                       ],
          //                     ),
          //                   ],
          //                 )),
          //           ],
          //         ),
          //       );
          //     }),
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
