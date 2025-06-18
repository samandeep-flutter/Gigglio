import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/home_bloc/home_bloc.dart';
import 'package:gigglio/business_logic/messages_bloc/messages_bloc.dart';
import 'package:gigglio/business_logic/profile_bloc/profile_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/home_view/home_screen.dart';
import 'package:gigglio/presentation/messages_view/messages_screen.dart';
import 'package:gigglio/presentation/profile_view/profile_screen.dart';
import 'package:gigglio/business_logic/root_bloc.dart';
import 'package:go_router/go_router.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> with TickerProviderStateMixin {
  @override
  void initState() {
    final bloc = context.read<RootBloc>();
    bloc.tabController =
        TabController(length: bloc.tabList.length, vsync: this);
    bloc.add(RootInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RootBloc>();
    final scheme = context.scheme;

    return Scaffold(
      backgroundColor: scheme.background,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(bottom: Dimens.sizeSmall),
          child: Container(
        margin: Utils.paddingHoriz(Dimens.sizeMedium),
        decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(Dimens.borderDefault),
            boxShadow: [
              BoxShadow(
                color: scheme.textColor.withAlpha(80),
                blurRadius: Dimens.sizeLarge,
                spreadRadius: Dimens.sizeLarge,
                offset: const Offset(0, Dimens.sizeDefault),
              )
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.borderDefault),
            child: BlocBuilder<RootBloc, RootState>(
                buildWhen: (pr, cr) => pr.index != cr.index,
                builder: (context, state) {
                  return BottomNavigationBar(
                    items: bloc.tabList,
                    currentIndex: state.index,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: scheme.primary,
                    unselectedItemColor: scheme.disabled,
                    backgroundColor: scheme.surface,
                    onTap: (index) {
                      if (index == 1) {
                        context.pushNamed(AppRoutes.newPost);
                        return;
                      }
                      bloc.add(RootIndexChanged(index));
                    },
                  );
                })),
      )),
      body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => HomeBloc()),
            BlocProvider(create: (_) => ProfileBloc()),
            BlocProvider(create: (_) => MessagesBloc()),
          ],
          child: TabBarView(
            controller: bloc.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              SizedBox.shrink(),
              MessagesScreen(),
              ProfileScreen(),
            ],
          )),
    );
  }
}
