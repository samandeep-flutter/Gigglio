import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/utils.dart';

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

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(const MessagesState.init()) {
    on<MessagesInitial>(_onInit);
    on<MessagesSearched>(_onSearch,
        transformer: Utils.debounce(Durations.medium4));
    on<MessagesStream>(_onMessagesRefresh,
        transformer: Utils.debounce(Durations.medium1));
  }

  final messages = FirebaseFirestore.instance.collection(FBKeys.messages);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final userId = FirebaseAuth.instance.currentUser!.uid;

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

  void _getMessages() {
    try {
      final filter = Filter('users', arrayContains: userId);
      final _query = messages.where(filter);
      final query = _query.orderBy('last_updated', descending: true);
      query.snapshots().listen((event) {
        if (isClosed) return;
        final _chats = event.docs.map((e) {
          final message = MessagesDbModel.fromJson(e.data());
          return message.copyWith(id: e.id);
        }).toList();
        final chats = _chats.where((e) => e.messages.isNotEmpty).toList();
        add(MessagesStream(chats));
      }, onError: (e) => logPrint(e, 'Messages'));
    } catch (e) {
      logPrint(e, 'Messages');
    }
  }

  _onMessagesRefresh(MessagesStream event, Emitter<MessagesState> emit) async {
    final List<MessagesModel> messages = [];
    try {
      for (final message in event.messages) {
        final _id = message.users.firstWhere((element) => element != userId);
        final _user = await users.doc(_id).get();

        messages.add(MessagesModel.fromDB(
            user: UserDetails.fromJson(_user.data()!), model: message));
      }
      _allMessages = messages;
      emit(state.copyWith(messages: messages));
    } catch (e) {
      logPrint(e, 'Messages');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
