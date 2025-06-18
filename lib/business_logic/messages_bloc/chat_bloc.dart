import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/box_services.dart';
import '../../data/utils/app_constants.dart';

class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatEvent {
  final String? id;
  final UserDetails user;
  const ChatInitial(this.id, {required this.user});

  @override
  List<Object?> get props => [id, user, ...super.props];
}

class ChatReadRecipts extends ChatEvent {}

class ChatSendMessage extends ChatEvent {}

class ChatFromDB extends ChatEvent {}

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

  const ChatState({
    required this.isLoading,
    required this.profile,
    required this.messages,
    required this.userData,
  });

  const ChatState.init()
      : isLoading = true,
        profile = null,
        userData = const [],
        messages = const [];

  ChatState copyWith({
    bool? isLoading,
    UserDetails? profile,
    List<Messages>? messages,
    List<UserData>? userData,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
      userData: userData ?? this.userData,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, messages, userData];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState.init()) {
    on<ChatInitial>(_onInit);
    on<ChatFromDB>(_fromDB);
    on<ChatStream>(_stream);
    on<ChatReadRecipts>(_readRecipts,
        transformer: Utils.debounce(Durations.long1));
    on<ChatSendMessage>(_sendMessage);
  }

  final messages = FirebaseFirestore.instance.collection(FBKeys.messages);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final box = BoxServices.instance;

  final messageContr = TextEditingController();
  final messageKey = GlobalKey<FormFieldState>();
  final scrollContr = ScrollController();

  String? chatId;

  Future<void> _chatStream() async {
    messages.doc(chatId).snapshots().listen((doc) {
      if (isClosed) return;
      final message = MessagesDbModel.fromJson(doc.data()!);
      add(ChatStream(message.copyWith(id: doc.id)));
    }, onError: (e) => logPrint(e, 'chat stream'));
  }

  void onPop(bool canPop, [result]) {
    if (state.messages.isEmpty) return;
    final _messages = state.messages.map((e) => e.toJson()).toList();
    box.write(BoxKeys.chat(chatId!), _messages);
  }

  _onInit(ChatInitial event, Emitter<ChatState> emit) async {
    emit(state.copyWith(profile: event.user));
    scrollContr.addListener(_listener);
    try {
      final filter = Filter('users', arrayContains: userId);
      if (event.id?.isNotEmpty ?? false) throw const FormatException();
      try {
        final _chats = await messages.where(filter).get();
        final chat = _chats.docs.firstWhere((e) {
          final list = e.data()['users'] as List;
          return list.contains(event.user.id);
        });
        chatId = chat.id;
      } catch (_) {
        emit(state.copyWith(isLoading: false));
        final message = MessagesDbModel(
          users: [userId, event.user.id],
          userData: [UserData.newUser(userId), UserData.newUser(event.user.id)],
        );
        final doc = await messages.add(message.toJson());
        chatId = doc.id;
      }
    } on FormatException {
      chatId = event.id;
    } catch (e) {
      logPrint(e, 'Chat');
    } finally {
      add(ChatFromDB());
      Future(_chatStream);
    }
  }

  _fromDB(ChatFromDB event, Emitter<ChatState> emit) {
    final List json = box.read(BoxKeys.chat(chatId!)) ?? [];
    final _messages =
        List<Messages>.from(json.map((e) => Messages.fromJson(e)));
    emit(state.copyWith(messages: _messages));
    Future(() async {
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        final pos = scrollContr.position.maxScrollExtent;
        scrollContr.jumpTo(pos);
      } catch (_) {}
    });
  }

  void _stream(ChatStream event, Emitter<ChatState> emit) async {
    try {
      final messages = List<MessagesDb>.from(event.chat.messages);
      messages.removeWhere((e) => state.messages.any((f) {
            return f.dateTime == e.dateTime;
          }));
      final data = event.chat.userData;
      final List<Messages> _messages = [];
      for (final message in messages) {
        try {
          if (message.post != null) throw Exception();
          _messages.add(Messages.fromDb(db: message));
        } catch (_) {
          final path = message.post?.split('/').last;
          final _doc = await posts.doc(path).get();
          final _post = PostDbModel.fromJson(_doc.data()!);
          final _author = await users.doc(_post.author).get();
          final author = UserDetails.fromJson(_author.data()!);
          final post = PostModel.fromDb(user: author, post: _post);
          _messages.add(Messages.fromDb(db: message, post: post));
        }
      }
      emit(state.copyWith(
          messages: [...state.messages, ..._messages], userData: data));
      if (state.messages.isEmpty) return;
      final index = state.userData.indexWhere((e) => e.id == userId);
      final userData = List<UserData>.from(state.userData);
      final seen = userData[index].seen;
      if (seen?.isAfter(state.messages.last.dateTime) ?? false) return;
      final pos = scrollContr.position.maxScrollExtent;
      if (!scrollContr.hasClients || pos == 0) add(ChatReadRecipts());
      scrollContr.jumpTo(pos);
    } catch (e) {
      logPrint(e, 'Chat');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _listener() {
    try {
      final direction = scrollContr.position.userScrollDirection;
      if (direction == ScrollDirection.forward) return;
      final pixels = scrollContr.position.pixels;
      final _scrollAt = double.parse(pixels.toStringAsFixed(2));
      final message = state.messages.firstWhere((e) {
        if ((e.scrollAt ?? 0) == 0) return false;
        return e.scrollAt! >= _scrollAt;
      });
      final index = state.userData.indexWhere((e) => e.id == userId);
      final userData = List<UserData>.from(state.userData);
      if (userData[index].seen?.isAfter(message.dateTime) ?? false) return;
    } catch (_) {}
    add(ChatReadRecipts());
  }

  void _readRecipts(ChatReadRecipts event, Emitter<ChatState> emit) async {
    if (state.userData.isEmpty) return;
    final index = state.userData.indexWhere((e) => e.id == userId);
    final userData = List<UserData>.from(state.userData);
    try {
      if (scrollContr.position.maxScrollExtent == 0) throw Exception();
      final pixels = scrollContr.position.pixels;
      final _scrollAt = double.parse(pixels.toStringAsFixed(2));
      final message = state.messages.firstWhere((e) {
        if ((e.scrollAt ?? 0) == 0) return false;
        return e.scrollAt! >= _scrollAt;
      });
      if (userData[index].seen?.isBefore(message.dateTime) ?? false) {
        userData[index] = userData[index].copyWith(seen: message.dateTime);
        final _userData = userData.map((e) => e.toJson()).toList();
        messages.doc(chatId).update({'user_data': _userData});
      }
    } catch (_) {
      final last = state.messages.last.dateTime;
      if (userData[index].seen?.isAfter(last) ?? false) return;
      userData[index] = userData[index].copyWith(seen: DateTime.now());
      final data = userData.map((e) => e.toJson()).toList();
      messages.doc(chatId).update({'user_data': data});
    } finally {
      emit(state.copyWith(userData: userData));
    }
  }

  void _sendMessage(ChatSendMessage event, Emitter<ChatState> emit) async {
    final text = messageContr.text.trim();
    if (text.isEmpty) return;
    final dateTime = DateTime.now();
    final position = scrollContr.position;
    try {
      final scrollAt = position.pixels > 0 ? position.pixels : null;
      final _scrollAt = double.tryParse(scrollAt?.toStringAsFixed(2) ?? '');
      final message = MessagesDb.text(
          author: userId, text: text, dateTime: dateTime, scrollAt: _scrollAt);
      await messages.doc(chatId).update({
        'messages': FieldValue.arrayUnion([message.toJson()]),
        'last_updated': dateTime.toIso8601String(),
      });
      add(ChatReadRecipts());
    } catch (e) {
      logPrint(e, 'Chat');
    } finally {
      messageContr.clear();
    }
  }
}
