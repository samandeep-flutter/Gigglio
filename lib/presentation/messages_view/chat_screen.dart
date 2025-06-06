import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/image_resources.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/presentation/messages_view/message_tile.dart';
import 'package:gigglio/presentation/widgets/base_widget.dart';
import 'package:gigglio/presentation/widgets/my_cached_image.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:go_router/go_router.dart';
import '../../business_logic/messages_bloc/chat_bloc.dart';
import '../widgets/my_text_field_widget.dart';

class ChatScreen extends StatefulWidget {
  final String? id;
  final UserDetails user;
  const ChatScreen(this.id, {super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    final bloc = context.read<ChatBloc>();
    bloc.add(ChatInitial(widget.id, user: widget.user));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    final scheme = context.scheme;

    return BaseWidget(
      padding: EdgeInsets.zero,
      resizeBottom: false,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImageRes.chatBackground),
          fit: BoxFit.cover,
        ),
      ),
      appBar: AppBar(
        backgroundColor: scheme.surface,
        centerTitle: false,
        titleSpacing: Dimens.zero,
        title: PopScope(
          onPopInvokedWithResult: bloc.onPop,
          child: BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (pr, cr) => pr.profile != cr.profile,
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => toProfile(state.profile?.id),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: MyCachedImage(state.profile?.image,
                        isAvatar: true, avatarRadius: Dimens.sizeMedium),
                    title: Text(state.profile?.displayName ?? ''),
                    titleTextStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: scheme.textColor,
                        fontSize: Dimens.fontExtraDoubleLarge),
                    subtitle: state.profile?.bio != null
                        ? Text(state.profile?.bio ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    subtitleTextStyle: TextStyle(
                        color: scheme.textColorLight, fontSize: Dimens.fontMed),
                    trailing: const SizedBox.shrink(),
                  ),
                );
              }),
        ),
        actions: [const SizedBox(width: Dimens.sizeDefault)],
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: _BottomBar(),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final other = state.userData
                .firstWhereOrNull((e) => e.id == state.profile!.id);
            // final index = messages!.userData.indexWhere((e) => e.id == user!.id);
            // if (messages!.userData[index].seen != messages!.messages.length) {
            //   _readRecipt(messages);
            // }
            return Stack(
              children: [
                ListView.builder(
                    padding: EdgeInsets.only(bottom: Dimens.sizeDefault),
                    controller: bloc.scrollContr,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final notNull = message.scrollAt != null;
                      bool isSeen = notNull
                          ? (other?.scrollAt ?? 0) >= message.scrollAt!
                          : other?.seen?.isAfter(message.dateTime) ?? false;

                      Messages? _above;
                      try {
                        _above = state.messages[index - 1];
                      } catch (_) {}
                      Messages? _below;
                      try {
                        _below = state.messages[index + 1];
                      } catch (_) {}

                      final sameAbove = message.author == _above?.author;
                      final sameBelow = message.author == _below?.author;

                      final _now = message.dateTime.subtract(Duration(days: 1));
                      final diff =
                          message.dateTime.difference(_above?.dateTime ?? _now);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (diff.inDays > 0)
                            Container(
                              margin: EdgeInsets.all(Dimens.sizeSmall),
                              padding: EdgeInsets.symmetric(
                                  vertical: Dimens.sizeExtraSmall,
                                  horizontal: Dimens.sizeMedSmall),
                              decoration: BoxDecoration(
                                color: scheme.background.withAlpha(150),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(Utils.formatDate(message.dateTime)),
                            ),
                          MessageTile(message,
                              seen: isSeen,
                              sameUserAbove: sameAbove,
                              sameUserBelow: sameBelow),
                        ],
                      );
                    }),
                if (state.isLoading)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.all(Dimens.sizeSmall),
                      padding: EdgeInsets.symmetric(
                          vertical: Dimens.sizeExtraSmall,
                          horizontal: Dimens.sizeMedSmall),
                      decoration: BoxDecoration(
                        color: scheme.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoActivityIndicator(),
                          SizedBox(width: Dimens.sizeDefault),
                          Text('Updating...')
                        ],
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  void toProfile(String? id) {
    context.pushNamed(AppRoutes.gotoProfile, extra: id);
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    final scheme = context.scheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                fieldKey: bloc.messageKey,
                maxLines: 1,
                title: 'Message',
                backgroundColor: scheme.surface,
                borderRadius: BorderRadius.circular(Dimens.borderDefault),
                margin: const EdgeInsets.only(left: Dimens.sizeSmall),
                capitalization: TextCapitalization.sentences,
                controller: bloc.messageContr,
              ),
            ),
            const SizedBox(width: Dimens.sizeSmall),
            SizedBox.square(
              dimension: Dimens.sizeExtraDoubleLarge,
              child: IconButton.filled(
                onPressed: () => bloc.add(ChatSendMessage()),
                icon: const Icon(Icons.send),
              ),
            ),
            const SizedBox(width: Dimens.sizeSmall),
          ],
        ),
        const SizedBox(height: Dimens.sizeSmall),
        SafeArea(child: SizedBox(height: context.bottomInsets))
      ],
    );
  }
}
