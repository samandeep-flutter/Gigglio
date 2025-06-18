import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/widgets/my_text_field_widget.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/presentation/widgets/shimmer_widget.dart';
import 'package:gigglio/presentation/widgets/top_widgets.dart';
import 'package:gigglio/business_logic/messages_bloc/messages_bloc.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    final bloc = context.read<MessagesBloc>();
    bloc.add(MessagesInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MessagesBloc>();
    final scheme = context.scheme;

    return Scaffold(
      backgroundColor: scheme.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.messages),
        titleTextStyle: Utils.defTitleStyle,
        actions: [
          TextButton.icon(
            onPressed: () => context.pushNamed(AppRoutes.newChat),
            label: const Text(StringRes.newChat),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: Dimens.sizeSmall)
        ],
        centerTitle: false,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: SearchTextField(
              title: 'Search',
              compact: true,
              backgroundColor: scheme.surface,
              margin: Utils.paddingHoriz(Dimens.sizeDefault),
              controller: bloc.searchContr,
            )),
      ),
      body: BlocBuilder<MessagesBloc, MessagesState>(
        buildWhen: (pr, cr) {
          final loading = pr.isLoading != cr.isLoading;
          final messages = pr.messages != cr.messages;
          return loading || messages;
        },
        builder: (context, state) {
          if (state.isLoading) return const MessagesShimmer();
          if (state.messages.isEmpty) {
            return const ToolTipWidget(title: StringRes.noMessages);
          }

          return ListView.builder(
              itemCount: state.messages.length,
              padding: const EdgeInsets.only(top: Dimens.sizeLarge),
              itemBuilder: (context, index) {
                final chat = state.messages[index];

                // final unseen=state.messages.where((e)=>e.)

                MessagesDb? last;
                if (chat.messages.isNotEmpty) last = chat.messages.last;
                return ListTile(
                  onTap: () => toChat(chat.id!, user: chat.user),
                  leading: MyAvatar(chat.user.image,
                      id: chat.user.id, isAvatar: true),
                  title: Text(chat.user.displayName),
                  subtitle: Builder(builder: (context) {
                    if (last?.post?.isNotEmpty ?? false) {
                      return Row(
                        children: [
                          Icon(Icons.photo,
                              size: Dimens.sizeMedium, color: scheme.disabled),
                          const SizedBox(width: Dimens.sizeSmall),
                          const Text(StringRes.postShared)
                        ],
                      );
                    }
                    return Text(last?.text ?? '',
                        maxLines: 1, overflow: TextOverflow.ellipsis);
                  }),
                  subtitleTextStyle: context.subtitleTextStyle,
                  trailing: Text(
                    Utils.timeFromNow(last?.dateTime),
                    style: TextStyle(color: scheme.disabled),
                  ),
                );
              });
        },
      ),
    );
  }

  void toChat(String id, {required UserDetails user}) {
    final params = {'id': id};
    context.pushNamed(AppRoutes.chatScreen,
        extra: user, queryParameters: params);
  }
}
