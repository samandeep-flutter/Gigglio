import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../../business_logic/home_bloc/home_bloc.dart';
import 'post_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    final bloc = context.read<HomeBloc>();
    bloc.add(HomeInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        automaticallyImplyLeading: false,
        title: const Text(StringRes.appName),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoutes.notifications),
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.favorite_border_rounded),
                BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (pr, cr) => pr.notiFetch != cr.notiFetch,
                    builder: (context, state) {
                      final noti = state.notiFetch;

                      return BlocBuilder<RootBloc, RootState>(
                          buildWhen: (pr, cr) => pr.profile != cr.profile,
                          builder: (context, state) {
                            final date = state.profile?.notiSeen;

                            if (date == null) return const SizedBox.shrink();
                            if ((noti?.isAfter(date) ?? false)) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: scheme.primary,
                                ),
                                child: SizedBox.square(dimension: 10),
                              );
                            }
                            return const SizedBox.shrink();
                          });
                    })
              ],
            ),
          ),
          const SizedBox(width: Dimens.sizeDefault),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async => bloc.add(HomeRefresh()),
        child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (pr, cr) => pr.loading != cr.loading,
            builder: (context, state) {
              if (state.loading) {
                return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(2, (_) => const PostTileShimmer()));
              }

              return ListView.builder(
                  itemCount: state.posts.length,
                  padding: EdgeInsets.only(bottom: context.height * .1),
                  itemBuilder: (context, index) {
                    return PostTile(state.posts[index], reload: reload);
                  });
            }),
      ),
    );
  }

  void reload() {
    final bloc = context.read<HomeBloc>();
    bloc.add(HomeRefresh(loading: false));
  }
}
