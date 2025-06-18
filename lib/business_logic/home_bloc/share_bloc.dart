import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/messages_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/utils.dart';

class ShareEvent extends Equatable {
  const ShareEvent();

  @override
  List<Object?> get props => [];
}

class ShareInitial extends ShareEvent {}

class SharePost extends ShareEvent {
  final String postId;
  const SharePost(this.postId);

  @override
  List<Object?> get props => [postId, ...super.props];
}

class SharePostTrigger extends ShareEvent {
  final String postId;
  const SharePostTrigger(this.postId);

  @override
  List<Object?> get props => [postId, ...super.props];
}

class ShareSelected extends ShareEvent {
  final String userId;
  const ShareSelected(this.userId);

  @override
  List<Object?> get props => [userId, ...super.props];
}

class ShareState extends Equatable {
  final bool loading;
  final bool shareLoading;
  final List<String> selected;
  final List<UserDetails> friends;
  final bool success;
  const ShareState({
    required this.loading,
    required this.shareLoading,
    required this.selected,
    required this.friends,
    required this.success,
  });

  const ShareState.init()
      : loading = true,
        shareLoading = false,
        success = false,
        selected = const [],
        friends = const [];

  ShareState copyWith({
    bool? loading,
    bool? shareLoading,
    List<String>? selected,
    List<UserDetails>? friends,
    bool? success,
  }) {
    return ShareState(
      loading: loading ?? this.loading,
      shareLoading: shareLoading ?? this.shareLoading,
      selected: selected ?? this.selected,
      friends: friends ?? this.friends,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props =>
      [loading, shareLoading, selected, friends, success];
}

class ShareBloc extends Bloc<ShareEvent, ShareState> {
  ShareBloc() : super(const ShareState.init()) {
    on<ShareInitial>(_onInit);
    on<SharePost>(_onShare);
    on<SharePostTrigger>(_onTrigger,
        transformer: Utils.debounce(Durations.long4));
    on<ShareSelected>(_onSelected);
  }
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final messages = FirebaseFirestore.instance.collection(FBKeys.messages);
  final userId = FirebaseAuth.instance.currentUser!.uid;

  void _onInit(ShareInitial event, Emitter<ShareState> emit) async {
    emit(state.copyWith(selected: []));
    try {
      final _query = await users.where('friends', arrayContains: userId).get();
      final friends = _query.docs.map((e) => UserDetails.fromJson(e.data()));
      emit(state.copyWith(friends: friends.toList()));
    } catch (e) {
      logPrint(e, 'onInit');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void _onSelected(ShareSelected event, Emitter<ShareState> emit) async {
    final selected = List<String>.from(state.selected);
    if (selected.contains(event.userId)) {
      selected.remove(event.userId);
    } else {
      selected.add(event.userId);
    }
    emit(state.copyWith(selected: selected));
  }

  void _onShare(SharePost event, Emitter<ShareState> emit) async {
    emit(state.copyWith(shareLoading: true));
    add(SharePostTrigger(event.postId));
  }

  void _onTrigger(SharePostTrigger event, Emitter<ShareState> emit) async {
    try {
      final filter = Filter('users', arrayContains: userId);
      final query = await messages.where(filter).get();
      final _post = AppConstants.share(event.postId);
      final message = MessagesDb.post(
          author: userId, dateTime: DateTime.now(), post: _post);
      for (final user in state.selected) {
        try {
          final doc = query.docs.firstWhere((e) {
            final list = List<String>.from(e.data()['users']);
            return list.contains(user);
          });
          messages.doc(doc.id).update({
            'messages': FieldValue.arrayUnion([message.toJson()])
          });
        } catch (_) {
          final chat = MessagesDbModel(
            users: [userId, user],
            messages: [message],
            userData: [UserData.newUser(userId), UserData.newUser(user)],
          );
          messages.add(chat.toJson());
        }
      }
    } catch (e) {
      logPrint(e, 'Share');
    } finally {
      emit(state.copyWith(shareLoading: false, success: true));
    }
  }
}
