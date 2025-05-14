import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/business_logic/messages_bloc/new_chat_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../data/utils/string.dart';
import '../widgets/my_text_field_widget.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  @override
  void initState() {
    final bloc = context.read<NewChatBloc>();
    bloc.add(NewChatInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NewChatBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: Text(StringRes.newChat),
        titleTextStyle: Utils.defTitleStyle,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: SearchTextField(
              title: 'Search',
              compact: true,
              controller: bloc.newChatContr,
              margin: Utils.paddingHoriz(Dimens.sizeDefault),
              backgroundColor: scheme.surface,
            )),
      ),
      child: BlocBuilder<NewChatBloc, NewChatState>(buildWhen: (pr, cr) {
        final loading = pr.isLoading != cr.isLoading;
        final users = pr.users != cr.users;
        return loading || users;
      }, builder: (context, state) {
        if (state.isLoading) {
          return ListView(
            padding: const EdgeInsets.only(top: Dimens.sizeLarge),
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(3, (_) {
              return const UserTileShimmer(trailing: SizedBox());
            }),
          );
        }

        if (state.users.isEmpty) {
          return ToolTipWidget(title: StringRes.noFriends);
        }
        return ListView.builder(
            padding: const EdgeInsets.only(top: Dimens.sizeLarge),
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return ListTile(
                  contentPadding: Utils.paddingHoriz(Dimens.sizeLarge),
                  onTap: () => toChat(user),
                  leading: MyAvatar(user.image, id: user.id, isAvatar: true),
                  title: Text(user.displayName),
                  subtitle: Text(user.bio ?? StringRes.defBio),
                  subtitleTextStyle: context.subtitleTextStyle);
            });
      }),
    );
  }

  void toChat(UserDetails user) {
    context.replaceNamed(AppRoutes.chatScreen, extra: user);
  }
}
