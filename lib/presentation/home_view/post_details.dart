import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/post_details_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/color_resources.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/home_view/share_tile.dart';
import 'package:gigglio/presentation/widgets/my_alert_dialog.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';

class PostDetails extends StatefulWidget {
  final PostModel post;
  final VoidCallback reload;
  const PostDetails(this.post, this.reload, {super.key});

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails>
    with TickerProviderStateMixin {
  @override
  void initState() {
    final bloc = context.read<PostDetailsBloc>();
    bloc.add(PostDetailsInitial(widget.post.author.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostDetailsBloc>();

    return MyBottomSheet(
      title: StringRes.actions,
      vsync: this,
      child: Padding(
        padding: Utils.paddingHoriz(Dimens.sizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<RootBloc, RootState>(
              builder: (context, state) {
                final id = widget.post.author.id;
                final friend = state.profile?.friends.contains(id);
                if (!(friend ?? false)) return const SizedBox.shrink();
                return CustomListTile(
                  onTap: () => bloc.add(PostUserUnfriend(id)),
                  leading: Icons.person_remove_outlined,
                  title: StringRes.unFriend,
                );
              },
            ),
            BlocBuilder<RootBloc, RootState>(
              builder: (context, state) {
                final id = widget.post.author.id;
                final friend = state.profile?.friends.contains(id);
                if (friend ?? false) return const SizedBox.shrink();

                final requests = state.profile!.requests.contains(id);
                return BlocBuilder<PostDetailsBloc, PostDetailsState>(
                    builder: (context, state) {
                  final requested =
                      state.profile?.requests.contains(bloc.userId);
                  return CustomListTile(
                    enable: !((requested ?? false) || requests),
                    onTap: () => bloc.add(PostAddFriend(id)),
                    leading: Icons.person_add_outlined,
                    title: requests
                        ? StringRes.inReq
                        : requested ?? false
                            ? StringRes.requested
                            : StringRes.sendFriendReq,
                  );
                });
              },
            ),
            CustomListTile(
              onTap: _sharePost,
              leading: Icons.share,
              title: StringRes.share,
            ),
            if (bloc.userId == widget.post.author.id)
              CustomListTile(
                onTap: () async {
                  context.pop();
                  try {
                    for (final image in widget.post.images) {
                      final ref = bloc.storage.refFromURL(image);
                      await ref.delete();
                    }
                    await bloc.posts.doc(widget.post.id).delete();
                  } catch (e) {
                    logPrint(e, 'DELETE POST');
                  }
                  widget.reload();
                },
                title: StringRes.deletePost,
                iconColor: ColorRes.error,
                splashColor: ColorRes.onError,
                leading: Icons.delete_outline,
              ),
            BlocListener<PostDetailsBloc, PostDetailsState>(
              listenWhen: (pr, cr) => pr.success != cr.success,
              listener: (context, state) {
                if (state.success) context.pop();
              },
              child: SizedBox(height: context.height * .05),
            )
          ],
        ),
      ),
    );
  }

  void _sharePost() {
    context.pop();
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: context.scheme.background,
        builder: (_) => ShareTileSheet(widget.post.id!));
  }
}
