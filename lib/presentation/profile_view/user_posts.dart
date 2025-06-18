import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/user_profile_bloc.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import '../home_view/post_tile.dart';

class UserPosts extends StatefulWidget {
  final int index;
  const UserPosts(this.index, {super.key});

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  @override
  void initState() {
    if (widget.index == 0) return;
    final bloc = context.read<UserProfileBloc>();
    bloc.add(UserProfileScrollTo(widget.index));
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
          buildWhen: (pr, cr) => pr.loading != cr.loading,
          builder: (context, state) {
            if (state.loading) {
              return SizedBox(width: 100, height: 20, child: Shimmer.box);
            } else if (bloc.userId == state.other!.id) {
              return const Text(StringRes.myPosts);
            }
            return Text('${state.other!.displayName}\'s Posts');
          },
        ),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: false,
      ),
      padding: EdgeInsets.zero,
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
          buildWhen: (pr, cr) => pr.loading != cr.loading,
          builder: (context, state) {
            if (state.loading) {
              return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(2, (_) => const PostTileShimmer()));
            }

            return ListView.builder(
                controller: bloc.postController,
                itemCount: state.posts.length,
                padding: EdgeInsets.only(bottom: context.height * .1),
                itemBuilder: (context, index) {
                  return PostTile(state.posts[index], reload: reload);
                });
          }),
    );
  }

  void reload() {
    final bloc = context.read<UserProfileBloc>();
    bloc.add(UserPostsRefresh());
  }
}
