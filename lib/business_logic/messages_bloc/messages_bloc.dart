import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:rxdart/rxdart.dart';

class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesEvent {}

class MessagesStream extends MessagesEvent {
  final List<MessagesDbModel> messages;

  const MessagesStream(this.messages);

  @override
  List<Object?> get props => [messages, ...super.props];
}

class MessagesSearched extends MessagesEvent {}

class MessagesState extends Equatable {
  final bool isLoading;
  final List<MessagesModel> messages;

  const MessagesState({
    required this.isLoading,
    required this.messages,
  });

  const MessagesState.init()
      : messages = const [],
        isLoading = true;

  MessagesState copyWith({bool? isLoading, List<MessagesModel>? messages}) {
    return MessagesState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [isLoading, messages];
}

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(const MessagesState.init()) {
    on<MessagesInitial>(_onInit);
    on<MessagesSearched>(_onSearch, transformer: _debounce(Durations.medium4));
    on<MessagesStream>(_onMessagesRefresh,
        transformer: _debounce(Durations.medium1));
  }

  final AuthServices auth = getIt();
  final messages = FirebaseFirestore.instance.collection(FBKeys.messages);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);

  final searchContr = TextEditingController();
  List<MessagesModel> _allMessages = [];

  _onInit(MessagesInitial event, Emitter<MessagesState> emit) async {
    searchContr.addListener(_listener);
    Future(_getMessages);
  }

  void _listener() => add(MessagesSearched());

  void _onSearch(MessagesSearched event, Emitter<MessagesState> emit) async {
    final query = searchContr.text.trim().toLowerCase();
    try {
      final messages = _allMessages.where((e) {
        final name = e.user.displayName.toLowerCase();
        return name.contains(query);
      }).toList();
      emit(state.copyWith(messages: messages));
    } catch (e) {
      logPrint(e, 'Messages');
    }
  }

  Future<void> _getMessages() async {
    try {
      final id = auth.user!.id;
      final query = messages
          .where(Filter.and(Filter('users', arrayContains: id),
              Filter('messages', isNotEqualTo: [])))
          .orderBy('messages');
      final _query = query.orderBy('last_updated', descending: true);
      _query.snapshots().listen((event) async {
        if (isClosed) return;
        final messages =
            event.docs.map((e) => MessagesDbModel.fromJson(e.data()));

        add(MessagesStream(messages.toList()));
      });
    } catch (e) {
      logPrint(e, 'Messages');
    }
  }

  _onMessagesRefresh(MessagesStream event, Emitter<MessagesState> emit) async {
    final List<MessagesModel> messages = [];
    try {
      final id = auth.user!.id;
      for (final message in event.messages) {
        final _id = message.users.firstWhere((element) => element != id);
        final _user = await users.doc(_id).get();

        messages.add(MessagesModel(
          user: UserDetails.fromJson(_user.data()!),
          userData: message.userData,
          lastUpdated: message.lastUpdated,
          messages: message.messages,
        ));
      }
      _allMessages = messages;
      emit(state.copyWith(messages: messages));
    } catch (e) {
      logPrint(e, 'Messages');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // void gotoProfile(String id) =>
  //     Get.toNamed(AppRoutes.gotoProfile, arguments: id);

  // Future<void> onUserSearch() async {
  //   if (newChatContr.text.isEmpty) {
  //     usersList.value = allUsers;
  //     return;
  //   }
  //   seachedUsers.value = allUsers.where((e) {
  //     return e.displayName.toLowerCase().contains(newChatContr.text);
  //   }).toList();
  //   usersList.value = seachedUsers;
  //   return;
  // }

  // void toChatScreen(UserDetails otherUser, {bool replace = false}) {
  //   if (replace) {
  //     Get.offNamed(AppRoutes.chatScreen, arguments: otherUser);
  //     return;
  //   }
  //   Get.toNamed(AppRoutes.chatScreen, arguments: otherUser);
  // }
}
