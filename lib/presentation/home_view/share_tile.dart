import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/share_bloc.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/my_alert_dialog.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/loading_widgets.dart';

class ShareTileSheet extends StatefulWidget {
  final String postId;
  const ShareTileSheet(this.postId, {super.key});

  @override
  State<ShareTileSheet> createState() => _ShareTileSheetState();
}

class _ShareTileSheetState extends State<ShareTileSheet>
    with TickerProviderStateMixin {
  @override
  void initState() {
    final bloc = context.read<ShareBloc>();
    bloc.add(ShareInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ShareBloc>();
    final scheme = context.scheme;

    return SizedBox(
      height: context.height * .55,
      child: MyBottomSheet(
        title: StringRes.share,
        vsync: this,
        isExpanded: true,
        bottomPadding: Dimens.sizeSmall,
        child: BaseWidget(
          padding: EdgeInsets.zero,
          bottom: Row(
            children: [
              BlocListener<ShareBloc, ShareState>(
                listenWhen: (pr, cr) => pr.success != cr.success,
                listener: (context, state) {
                  if (state.success) context.pop();
                },
                child: const SizedBox.shrink(),
              ),
              Expanded(
                child: BlocBuilder<ShareBloc, ShareState>(
                  buildWhen: (pr, cr) {
                    final loading = pr.shareLoading != cr.shareLoading;
                    final selected = pr.selected != cr.selected;
                    return loading || selected;
                  },
                  builder: (context, state) {
                    return LoadingButton(
                      width: double.infinity,
                      enable: state.selected.isNotEmpty,
                      border: Dimens.borderDefault,
                      isLoading: state.shareLoading,
                      margin: Utils.paddingHoriz(Dimens.sizeLarge),
                      onPressed: () => bloc.add(SharePost(widget.postId)),
                      child: const Text(StringRes.share),
                    );
                  },
                ),
              ),
            ],
          ),
          child: BlocBuilder<ShareBloc, ShareState>(
            buildWhen: (pr, cr) {
              final friends = pr.friends != cr.friends;
              final selected = pr.selected != cr.selected;
              final loading = pr.loading != cr.loading;
              return friends || selected || loading;
            },
            builder: (context, state) {
              if (state.loading) return const ShareShimmer();

              return GridView.builder(
                scrollDirection:
                    state.friends.length < 6 ? Axis.vertical : Axis.horizontal,
                padding: const EdgeInsets.only(bottom: Dimens.sizeDefault),
                itemCount: state.friends.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: state.friends.length < 6 ? 3 : 2,
                    crossAxisSpacing: Dimens.sizeSmall,
                    mainAxisSpacing: Dimens.sizeSmall),
                itemBuilder: (context, index) {
                  final user = state.friends[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          MyAvatar(
                            user.image,
                            isAvatar: true,
                            avatarRadius: Dimens.sizeExtraLarge,
                            onTap: () => bloc.add(ShareSelected(user.id)),
                          ),
                          if (state.selected.contains(user.id))
                            Container(
                              margin:
                                  const EdgeInsets.all(Dimens.sizeExtraSmall),
                              decoration: BoxDecoration(
                                  color: scheme.background,
                                  borderRadius: BorderRadius.circular(
                                      Dimens.borderLarge)),
                              child: Icon(Icons.check_circle_rounded,
                                  color: scheme.primary,
                                  size: Dimens.sizeMedium),
                            )
                        ],
                      ),
                      const SizedBox(height: Dimens.sizeSmall),
                      Text(
                        user.displayName,
                        maxLines: 1,
                        style: const TextStyle(fontSize: Dimens.fontMed),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
