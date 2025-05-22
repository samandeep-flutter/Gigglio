import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/utils.dart';
import '../../data/utils/app_constants.dart';

class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatEvent {
  final UserDetails user;
  const ChatInitial(this.user);

  @override
  List<Object?> get props => [user, ...super.props];
}

class ChatReadRecipts extends ChatEvent {}

class ChatScrollTo extends ChatEvent {}

class ChatSendMessage extends ChatEvent {}

class ChatStream extends ChatEvent {
  final MessagesDbModel chat;
  const ChatStream(this.chat);

  @override
  List<Object?> get props => [chat, ...super.props];
}

class ChatState extends Equatable {
  final bool isLoading;
  final UserDetails? profile;
  final List<Messages> messages;
  final List<UserData> userData;
  final int? scrollAt;

  const ChatState({
    required this.isLoading,
    required this.profile,
    required this.messages,
    required this.userData,
    required this.scrollAt,
  });

  const ChatState.init()
      : isLoading = true,
        profile = null,
        scrollAt = null,
        userData = const [],
        messages = const [];

  ChatState copyWith({
    bool? isLoading,
    UserDetails? profile,
    List<Messages>? messages,
    List<UserData>? userData,
    int? scrollAt,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
      userData: userData ?? this.userData,
      scrollAt: scrollAt ?? this.scrollAt,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, messages, userData, scrollAt];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState.init()) {
    on<ChatInitial>(_onInit);
    on<ChatStream>(_stream);
    on<ChatScrollTo>(_scrollTo, transformer: Utils.debounce(Durations.medium4));
    on<ChatReadRecipts>(_readRecipts);
    on<ChatSendMessage>(_sendMessage);
  }

  final messages = FirebaseFirestore.instance.collection(FBKeys.messages);
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final messageContr = TextEditingController();
  final messageKey = GlobalKey<FormFieldState>();
  final scrollContr = ScrollController();

  String? chatId;

  Future<void> _chatStream() async {
    messages.doc(chatId).snapshots().listen((doc) {
      if (isClosed) return;
      add(ChatStream(MessagesDbModel.fromJson(doc.data()!)));
    });
  }

  _onInit(ChatInitial event, Emitter<ChatState> emit) async {
    emit(state.copyWith(profile: event.user));
    scrollContr.addListener(_listener);
    try {
      final filter = Filter('users', arrayContains: userId);
      try {
        final _chats = await messages.where(filter).get();
        final chat = _chats.docs.firstWhere((e) {
          final list = e.data()['users'] as List;
          return list.contains(event.user.id);
        });
        chatId = chat.id;
      } catch (_) {
        final message = MessagesDbModel(
          users: [userId, event.user.id],
          userData: [UserData.newUser(userId), UserData.newUser(event.user.id)],
        );
        final doc = await messages.add(message.toJson());
        chatId = doc.id;
      }
      Future(_chatStream);
    } catch (e) {
      logPrint(e, 'Chat');
    }
  }

  void _stream(ChatStream event, Emitter<ChatState> emit) async {
    try {
      final _messages = List<Messages>.from(event.chat.messages);
      _messages.removeWhere((e) => state.messages.any((f) {
            return f.dateTime == e.dateTime;
          }));
      final data = event.chat.userData;
      emit(state.copyWith(
          messages: [...state.messages, ..._messages], userData: data));
      if (!scrollContr.hasClients) add(ChatReadRecipts());
    } catch (_) {
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _scrollTo(ChatScrollTo event, Emitter<ChatState> emit) async {
    final user = state.userData.firstWhere((e) => e.id == userId);
    final index = state.messages.indexWhere((e) => user.seen == e.dateTime);
    scrollContr.jumpTo(index.toDouble());
  }

  // void gotoPost(String id) => Get.toNamed(AppRoutes.gotoPost, arguments: id);

  void _listener() => add(ChatReadRecipts());

  void _readRecipts(ChatReadRecipts event, Emitter<ChatState> emit) async {
    final index = state.userData.indexWhere((e) => e.id == userId);
    final userData = List<UserData>.from(state.userData);
    try {
      final position = scrollContr.position;
      final _userData = userData[index]
          .copyWith(seen: DateTime.now(), scrollAt: position.pixels);
      userData[index] = _userData;
      emit(state.copyWith(scrollAt: position.pixels.toInt()));
    } catch (_) {
      final _userData = userData[index].copyWith(seen: DateTime.now());
      userData[index] = _userData;
    } finally {
      emit(state.copyWith(userData: userData));
      final _userData = userData.map((e) => e.toJson()).toList();
      messages.doc(chatId).update({'user_data': _userData});
    }
  }

  void _sendMessage(ChatSendMessage event, Emitter<ChatState> emit) async {
    final text = messageContr.text.trim();
    if (text.isEmpty) return;
    final dateTime = DateTime.now();
    final position = scrollContr.position;
    try {
      final scrollAt = position.pixels > 0 ? position.pixels : null;
      final pos = state.messages.length + 1;
      final message = Messages.text(
        author: userId,
        text: text,
        dateTime: dateTime,
        scrollAt: scrollAt,
        position: pos,
      );
      await messages.doc(chatId).update({
        'messages': FieldValue.arrayUnion([message.toJson()]),
        'last_updated': dateTime.toIso8601String(),
      });
      add(ChatReadRecipts());
      messageContr.clear();
    } catch (e) {
      logPrint(e, 'Chat');
    }
  }
}
