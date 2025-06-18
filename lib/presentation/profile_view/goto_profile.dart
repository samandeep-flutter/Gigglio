import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/user_profile_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/dimens.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/my_cached_image.dart';
import '../widgets/shimmer_widget.dart';

class GotoProfile extends StatefulWidget {
  final String userId;
  const GotoProfile({super.key, required this.userId});

  @override
  State<GotoProfile> createState() => _GotoProfileState();
}

class _GotoProfileState extends State<GotoProfile> {
  @override
  void initState() {
    final bloc = context.read<UserProfileBloc>();
    bloc.add(UserProfileInitial(widget.userId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();
    final scheme = context.scheme;

    return BaseWidget(
        appBar: AppBar(
          backgroundColor: scheme.background,
          title: BlocBuilder<UserProfileBloc, UserProfileState>(
              buildWhen: (pr, cr) {
            final loading = pr.loading != cr.loading;
            final other = pr.other != cr.other;
            return loading || other;
          }, builder: (context, state) {
            if (state.loading) {
              return SizedBox(height: 20, width: 100, child: Shimmer.box);
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.other?.displayName ?? '',
                    style: Utils.defTitleStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                  state.other?.email ?? '',
                  style: TextStyle(
                      fontSize: Dimens.fontMed, color: scheme.textColorLight),
                ),
              ],
            );
          }),
          centerTitle: false,
        ),
        padding: EdgeInsets.zero,
        child: ListView(
          children: [
            const SizedBox(height: Dimens.sizeLarge),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: Dimens.sizeLarge),
                BlocBuilder<UserProfileBloc, UserProfileState>(
                    buildWhen: (pr, cr) => pr.other != cr.other,
                    builder: (context, state) {
                      return MyCachedImage(
                        state.other?.image,
                        isAvatar: true,
                        avatarRadius: 50,
                      );
                    }),
                const SizedBox(width: Dimens.sizeLarge),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<UserProfileBloc, UserProfileState>(
                        buildWhen: (pr, cr) => pr.other != cr.other,
                        builder: (context, state) {
                          return Text(
                            state.other?.bio ?? '',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: scheme.textColorLight,
                                fontWeight: FontWeight.w500),
                          );
                        }),
                    const SizedBox(height: Dimens.sizeDefault),
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<UserProfileBloc, UserProfileState>(
                              buildWhen: (pr, cr) => pr.posts != cr.posts,
                              builder: (context, state) {
                                return FriendsTile(
                                  title: state.posts.length == 1
                                      ? 'Post'
                                      : 'Posts',
                                  count: state.posts.length,
                                );
                              }),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    )
                  ],
                )),
                const SizedBox(width: Dimens.sizeLarge),
              ],
            ),
            const SizedBox(height: Dimens.sizeLarge),
            BlocBuilder<UserProfileBloc, UserProfileState>(
              buildWhen: (pr, cr) {
                final loading = pr.loading != cr.loading;
                final request = pr.reqLoading != cr.reqLoading;
                return loading || request;
              },
              builder: (context, state) {
                if (state.loading || state.reqLoading) {
                  return const Row(children: [
                    SizedBox(width: Dimens.sizeLarge),
                    Expanded(
                        child: ShimmerButton(
                            borderRadius: Dimens.borderDefault,
                            height: Dimens.sizeExtraDoubleLarge)),
                    SizedBox(width: Dimens.sizeDefault),
                    Expanded(
                        child: ShimmerButton(
                            borderRadius: Dimens.borderDefault,
                            height: Dimens.sizeExtraDoubleLarge)),
                    SizedBox(width: Dimens.sizeLarge),
                  ]);
                }
                final id = state.profile?.id;
                final otherId = state.other?.id;
                final friend = state.other?.friends.contains(id) ?? false;
                final requested = state.other?.requests.contains(id) ?? false;
                final requests =
                    state.profile?.requests.contains(otherId) ?? false;

                return Row(
                  children: [
                    const SizedBox(width: Dimens.sizeLarge),
                    Expanded(
                      child: LoadingButton(
                          onPressed: () =>
                              bloc.add(UserProfileRequest(otherId!)),
                          enable: !(friend || requested),
                          width: double.infinity,
                          border: Dimens.borderMedSmall,
                          backgroundColor: scheme.onPrimaryContainer,
                          padding: const EdgeInsets.all(Dimens.sizeSmall),
                          child: Builder(builder: (context) {
                            if (friend) return const Text(StringRes.friends);
                            if (requested) return const Text(StringRes.requested);
                            if (requests) return const Text(StringRes.accept);
                            return const Text(StringRes.sendRequest);
                          })),
                    ),
                    const SizedBox(width: Dimens.sizeDefault),
                    Expanded(
                      child: LoadingButton(
                          enable: friend,
                          onPressed: () => toChat(state.other),
                          width: double.infinity,
                          border: Dimens.borderMedSmall,
                          padding: const EdgeInsets.all(Dimens.sizeSmall),
                          backgroundColor: scheme.onPrimaryContainer,
                          child: const Text(StringRes.sendMessage)),
                    ),
                    const SizedBox(width: Dimens.sizeLarge),
                  ],
                );
              },
            ),
            const SizedBox(height: Dimens.sizeLarge),
            const ListTile(
              minVerticalPadding: 0,
              visualDensity: VisualDensity.compact,
              leading: Icon(Icons.photo_library_outlined),
              title: Text(StringRes.posts),
            ),
            BlocBuilder<UserProfileBloc, UserProfileState>(buildWhen: (pr, cr) {
              final posts = pr.posts != cr.posts;
              final loding = pr.loading != cr.loading;
              return posts || loding;
            }, builder: (context, state) {
              if (state.loading) {
                return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimens.sizeExtraSmall),
                    gridDelegate: Utils.gridDelegate(3, spacing: 4),
                    itemCount: Dimens.sizeMedSmall.toInt(),
                    itemBuilder: (context, _) {
                      return const MyCachedImage.loading();
                    });
              }

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
                        child: MyCachedImage(item.images.first),
                      ),
                    );
                  });
            }),
          ],
        ));
  }

  void toPost(int index) {
    context.pushNamed(AppRoutes.userPosts, extra: index);
  }

  void toChat(UserDetails? user) {
    context.pushNamed(AppRoutes.chatScreen, extra: user);
  }
}
