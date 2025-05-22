import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/utils/color_resources.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../../business_logic/profile_bloc/add_friends_bloc.dart';
import '../widgets/base_widget.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_text_field_widget.dart';

class AddFriends extends StatefulWidget {
  const AddFriends({super.key});

  @override
  State<AddFriends> createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  @override
  void initState() {
    final bloc = context.read<AddFriendsBloc>();
    bloc.add(AddFriendsInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddFriendsBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.addFriends),
        titleTextStyle: Utils.defTitleStyle,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(kTextTabBarHeight),
            child: SearchTextField(
              compact: true,
              backgroundColor: scheme.surface,
              margin: Utils.paddingHoriz(Dimens.sizeDefault),
              title: 'Search by email',
              controller: bloc.friendContr,
            )),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BlocBuilder<RootBloc, RootState>(
                  buildWhen: (pr, cr) =>
                      pr.profile?.requests != cr.profile?.requests,
                  builder: (context, state) {
                    return TextButton(
                        onPressed: () =>
                            context.pushNamed(AppRoutes.viewRequests),
                        child: Text('${StringRes.viewRequests} '
                            '(${state.profile?.requests.length})'));
                  })
            ],
          ),
          BlocBuilder<AddFriendsBloc, AddFriendsState>(
              buildWhen: (pr, cr) => pr.users != cr.users,
              builder: (context, state) {
                if (state.users.isEmpty) {
                  return ToolTipWidget(
                    title: bloc.friendContr.text.isEmpty
                        ? StringRes.addFriendsDesc
                        : StringRes.noResults,
                    margin: EdgeInsets.symmetric(
                      vertical: context.height * .1,
                      horizontal: Dimens.sizeLarge,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
          Expanded(
            child: BlocBuilder<AddFriendsBloc, AddFriendsState>(
                buildWhen: (pr, cr) => pr.isLoading != cr.isLoading,
                builder: (context, state) {
                  return ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return ListTile(
                          onTap: () => toProfile(user.id),
                          contentPadding: Utils.paddingHoriz(Dimens.sizeLarge),
                          leading:
                              MyAvatar(user.image, isAvatar: true, id: user.id),
                          title: Text(user.displayName),
                          subtitle: Text(user.email,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitleTextStyle: context.subtitleTextStyle,
                          trailing:
                              BlocBuilder<AddFriendsBloc, AddFriendsState>(
                            buildWhen: (pr, cr) => pr.requested != cr.requested,
                            builder: (context, state) {
                              return _TrailingButton(user.id, state.requested);
                            },
                          ),
                        );
                      });
                }),
          )
        ],
      ),
    );
  }

  void toProfile(String id) {
    context.pushNamed(AppRoutes.gotoProfile, extra: id);
  }
}

class _TrailingButton extends StatelessWidget {
  final String id;
  final List<String> requested;

  const _TrailingButton(this.id, this.requested);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddFriendsBloc>();
    final scheme = context.scheme;

    return BlocBuilder<RootBloc, RootState>(
        buildWhen: (pr, cr) => pr.profile != cr.profile,
        builder: (context, state) {
          if (state.profile!.friends.contains(id)) {
            return LoadingButton(
                defWidth: true,
                compact: true,
                onPressed: () => bloc.add(RemoveAddedRFriend(id)),
                border: Dimens.borderSmall,
                backgroundColor: scheme.backgroundDark,
                foregroundColor: ColorRes.error,
                child: const Text(StringRes.remove));
          }
          final _requested = requested.contains(id);
          final iContain = state.profile!.requests.contains(id);
          return LoadingButton(
              defWidth: true,
              compact: true,
              onPressed: () => bloc.add(AddFriendRequest(id)),
              enable: !(iContain || _requested),
              border: Dimens.borderSmall,
              child: requested.contains(id)
                  ? const Text(StringRes.requested)
                  : state.profile!.requests.contains(id)
                      ? const Text(StringRes.inReq)
                      : const Text(StringRes.send));
        });
  }
}
