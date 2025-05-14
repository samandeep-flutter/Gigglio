import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:rxdart/rxdart.dart';

class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileEvent {
  final String userId;

  const UserProfileInitial(this.userId);

  @override
  List<Object?> get props => [userId, ...super.props];
}

class UserProfileRefresh extends UserProfileEvent {
  final String userId;

  const UserProfileRefresh(this.userId);

  @override
  List<Object?> get props => [userId, ...super.props];
}

class UserPostsRefresh extends UserProfileEvent {}

class UserProfileRequest extends UserProfileEvent {
  final String id;

  const UserProfileRequest(this.id);

  @override
  List<Object?> get props => [id, ...super.props];
}

class UserProfileScrollTo extends UserProfileEvent {
  final int index;
  const UserProfileScrollTo(this.index);

  @override
  List<Object?> get props => [index, ...super.props];
}

class UserProfileState extends Equatable {
  final bool loading;
  final bool reqLoading;
  final UserDetails? profile;
  final UserDetails? other;
  final List<PostModel> posts;

  const UserProfileState({
    required this.loading,
    required this.reqLoading,
    required this.profile,
    required this.other,
    required this.posts,
  });

  const UserProfileState.init()
      : loading = true,
        reqLoading = false,
        profile = null,
        other = null,
        posts = const [];

  UserProfileState copyWith({
    bool? loading,
    bool? reqLoading,
    UserDetails? profile,
    UserDetails? other,
    List<PostModel>? posts,
  }) {
    return UserProfileState(
      reqLoading: reqLoading ?? this.reqLoading,
      loading: loading ?? this.loading,
      other: other ?? this.other,
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
    );
  }

  @override
  List<Object?> get props => [loading, profile, other, posts];
}

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(UserProfileState.init()) {
    on<UserProfileInitial>(_onInit);
    on<UserProfileRefresh>(_onRefresh);
    on<UserPostsRefresh>(_onPostsRefresh);
    on<UserProfileRequest>(_onRequest);
    on<UserProfileScrollTo>(_scrollTo, transformer: _debounce(duration));
  }

  final duration = const Duration(milliseconds: 300);
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final postController = ScrollController();
  final AuthServices auth = getIt();

  _onInit(UserProfileInitial event, Emitter<UserProfileState> emit) async {
    emit(UserProfileState.init());
    try {
      add(UserProfileRefresh(event.userId));
      final query = this.posts.where('author', isEqualTo: event.userId);
      final json = await query.orderBy('date_time', descending: true).get();
      final posts = json.docs.map((e) {
        final post = PostModel.fromJson(e.data());
        return post.copyWith(id: e.id);
      }).toList();
      emit(state.copyWith(posts: posts));
    } catch (e) {
      logPrint(e, 'UserProfile');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  _onRefresh(UserProfileRefresh event, Emitter<UserProfileState> emit) async {
    try {
      final profile = Completer<UserDetails>();
      final other = Completer<UserDetails>();
      final onlyMe = auth.user!.id == event.userId;
      if (!onlyMe) {
        users.doc(auth.user!.id).get().then((snap) {
          profile.complete(UserDetails.fromJson(snap.data()!));
        });
      }
      users.doc(event.userId).get().then((snap) {
        other.complete(UserDetails.fromJson(snap.data()!));
      });
      UserDetails? _profile;
      if (!onlyMe) _profile = await profile.future;
      final _other = await other.future;
      emit(state.copyWith(profile: _profile, other: _other));
    } catch (e) {
      logPrint(e, 'refresh');
    } finally {
      emit(state.copyWith(reqLoading: false));
    }
  }

  _onPostsRefresh(
      UserPostsRefresh event, Emitter<UserProfileState> emit) async {
    try {
      final query = this.posts.where('author', isEqualTo: state.other!.id);
      final json = await query.orderBy('date_time', descending: true).get();
      final posts = json.docs.map((e) {
        final post = PostModel.fromJson(e.data());
        return post.copyWith(id: e.id);
      }).toList();
      emit(state.copyWith(posts: posts));
    } catch (e) {
      logPrint(e, 'UserProfile');
    }
  }

  _onRequest(UserProfileRequest event, Emitter<UserProfileState> emit) async {
    emit(state.copyWith(reqLoading: true));
    // TODO: insert request logic.
    add(UserProfileRefresh(state.other!.id));
  }

  _scrollTo(UserProfileScrollTo event, Emitter<UserProfileState> emit) async {
    try {
      final maxHeight = postController.position.maxScrollExtent;
      postController.animateTo(maxHeight * event.index,
          duration: Durations.medium1, curve: Curves.fastOutSlowIn);
    } catch (e) {
      logPrint(e, 'scrollTo');
    }
  }
}
