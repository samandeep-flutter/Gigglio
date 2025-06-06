import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/comments_bloc.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/my_alert_dialog.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import '../../data/utils/dimens.dart';
import '../../data/utils/string.dart';
import '../../data/utils/utils.dart';
import '../widgets/my_text_field_widget.dart';

class CommentSheet extends StatefulWidget {
  final String id;
  const CommentSheet(this.id, {super.key});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet>
    with TickerProviderStateMixin {
  @override
  void initState() {
    final bloc = context.read<CommentsBloc>();
    bloc.add(CommentsInitial(widget.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bloc = context.read<CommentsBloc>();

    return MyBottomSheet(
      title: StringRes.comments,
      vsync: this,
      isExpanded: true,
      bottomPadding: Dimens.sizeMedSmall,
      onClose: FocusManager.instance.primaryFocus?.unfocus,
      child: BaseWidget(
        bottom: Padding(
            padding: EdgeInsets.only(bottom: context.bottomInsets),
            child: Row(
              children: [
                const SizedBox(width: Dimens.sizeDefault),
                Expanded(
                  child: CustomTextField(
                    maxLines: 1,
                    defaultBorder: true,
                    backgroundColor: scheme.surface,
                    title: 'add a comment...',
                    capitalization: TextCapitalization.sentences,
                    controller: bloc.commentsContr,
                  ),
                ),
                const SizedBox(width: Dimens.sizeSmall),
                IconButton.filled(
                    onPressed: () => bloc.add(AddComment(widget.id)),
                    iconSize: Dimens.sizeMidLarge,
                    icon: const Icon(Icons.send)),
                const SizedBox(width: Dimens.sizeSmall),
              ],
            )),
        padding: Utils.paddingHoriz(Dimens.sizeDefault),
        child: BlocBuilder<CommentsBloc, CommentsState>(
          builder: (context, state) {
            if (state.loading) const CommentsShimmer();
            if (state.comments.isEmpty) {
              return ToolTipWidget(title: StringRes.noComments);
            }
            return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.comments.length,
                itemBuilder: (context, index) {
                  final comment = state.comments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimens.sizeSmall),
                    child: Row(
                      children: [
                        MyAvatar(comment.author.image,
                            isAvatar: true, id: comment.author.id),
                        const SizedBox(width: Dimens.sizeDefault),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.author.displayName,
                                    style: const TextStyle(
                                        fontSize: Dimens.fontMed),
                                  ),
                                  const SizedBox(width: Dimens.sizeSmall),
                                  Text(
                                    Utils.timeFromNow(comment.dateTime, 'ago'),
                                    style: TextStyle(
                                        fontSize: Dimens.fontMed,
                                        color: scheme.disabled),
                                  )
                                ],
                              ),
                              Text(comment.title),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
