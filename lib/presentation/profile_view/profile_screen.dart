import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/user_profile_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/my_cached_image.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/business_logic/profile_bloc/profile_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    final bloc = context.read<ProfileBloc>();
    bloc.add(ProfileInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        toolbarHeight: Dimens.sizeMidLarge,
      ),
      padding: EdgeInsets.zero,
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: Dimens.sizeLarge),
              BlocBuilder<RootBloc, RootState>(
                buildWhen: (pr, cr) => pr.profile?.image != cr.profile?.image,
                builder: (context, state) {
                  return MyCachedImage(state.profile?.image,
                      isAvatar: true, avatarRadius: 50);
                },
              ),
              const SizedBox(width: Dimens.sizeLarge),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimens.sizeSmall),
                  BlocBuilder<RootBloc, RootState>(
                      buildWhen: (pr, cr) =>
                          pr.profile?.displayName != cr.profile?.displayName,
                      builder: (context, state) {
                        return Text(
                          state.profile?.displayName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: Dimens.fontExtraDoubleLarge,
                              color: scheme.textColor,
                              fontWeight: FontWeight.w600),
                        );
                      }),
                  BlocBuilder<RootBloc, RootState>(
                      buildWhen: (pr, cr) =>
                          pr.profile?.email != cr.profile?.email,
                      builder: (context, state) {
                        return Text(
                          state.profile?.email ?? '',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: scheme.textColorLight,
                              fontSize: Dimens.fontMed),
                        );
                      }),
                  const SizedBox(height: Dimens.sizeSmall + 2),
                  BlocBuilder<RootBloc, RootState>(
                      buildWhen: (pr, cr) => pr.profile?.bio != cr.profile?.bio,
                      builder: (context, state) {
                        return Text(
                          state.profile?.bio ?? '',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: scheme.textColorLight,
                              fontWeight: FontWeight.w500),
                        );
                      }),
                  const SizedBox(height: Dimens.sizeDefault),
                  BlocBuilder<RootBloc, RootState>(
                    buildWhen: (pr, cr) {
                      final friends =
                          pr.profile?.friends != cr.profile?.friends;
                      final requests =
                          pr.profile?.requests != cr.profile?.requests;
                      return friends || requests;
                    },
                    builder: (context, state) {
                      if (state.profile == null) return const CountShimmer();
                      bool singleFriend = state.profile!.friends.length == 1;
                      bool singleRequest = state.profile!.requests.length == 1;
                      return Row(
                        children: [
                          Expanded(
                            child: FriendsTile(
                              title: singleFriend ? 'Friend' : 'Friends',
                              count: state.profile?.friends.length,
                              onTap: () =>
                                  context.pushNamed(AppRoutes.addFriends),
                            ),
                          ),
                          Expanded(
                            child: FriendsTile(
                              title: singleRequest ? 'Request' : 'Requests',
                              count: state.profile?.requests.length,
                              enable: state.profile!.requests.isNotEmpty,
                              onTap: () =>
                                  context.pushNamed(AppRoutes.viewRequests),
                            ),
                          )
                        ],
                      );
                    },
                  )
                ],
              )),
              const SizedBox(width: Dimens.sizeLarge),
            ],
          ),
          const SizedBox(height: Dimens.sizeLarge),
          Row(
            children: [
              const SizedBox(width: Dimens.sizeLarge),
              Expanded(
                child: ElevatedButton.icon(
                  style: buttonStyle,
                  onPressed: () => context.pushNamed(AppRoutes.editProfile),
                  label: const Text(StringRes.editProfile),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(width: Dimens.sizeDefault),
              Expanded(
                child: ElevatedButton.icon(
                  style: buttonStyle,
                  onPressed: () => context.pushNamed(AppRoutes.settings),
                  label: const Text(StringRes.settings),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
              const SizedBox(width: Dimens.sizeLarge),
            ],
          ),
          const SizedBox(height: Dimens.sizeLarge),
          const ListTile(
            minVerticalPadding: 0,
            visualDensity: VisualDensity.compact,
            leading: Icon(Icons.photo_library_outlined),
            title: Text(StringRes.myPosts),
          ),
          BlocBuilder<ProfileBloc, ProfileState>(
              buildWhen: (pr, cr) => pr.posts != cr.posts,
              builder: (context, state) {
                if (state.posts.isEmpty) {
                  return ToolTipWidget(
                    margin: EdgeInsets.only(top: context.height * .05),
                    title: StringRes.noPosts,
                    icon: Icon(Icons.camera_alt_outlined,
                        color: scheme.backgroundDark, size: 150),
                  );
                }
                return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimens.sizeExtraSmall),
                    gridDelegate: Utils.gridDelegate(3),
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final item = state.posts[index];
                      return InkWell(
                        onTap: () => toPost(index),
                        splashColor: Colors.black38,
                        child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: MyCachedImage(item.images.first)),
                      );
                    });
              }),
        ],
      ),
    );
  }

  void toPost(int index) {
    final bloc = context.read<UserProfileBloc>();
    bloc.add(UserProfileInitial(bloc.userId));
    context.pushNamed(AppRoutes.userPosts, extra: index);
  }

  ButtonStyle get buttonStyle {
    final scheme = context.scheme;
    return ElevatedButton.styleFrom(
      foregroundColor: scheme.onPrimary,
      backgroundColor: scheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.borderMedSmall)),
      padding: const EdgeInsets.symmetric(vertical: Dimens.sizeSmall),
    );
  }
}
