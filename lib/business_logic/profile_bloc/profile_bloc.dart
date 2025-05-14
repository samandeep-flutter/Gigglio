import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';

class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileEvent {}

class ProfileRefresh extends ProfileEvent {
  final UserDetails? user;

  const ProfileRefresh(this.user);

  @override
  List<Object?> get props => [user, ...super.props];
}

class ProfilePostsRefresh extends ProfileEvent {
  final List<PostModel>? posts;

  const ProfilePostsRefresh(this.posts);

  @override
  List<Object?> get props => [posts, ...super.props];
}

class ProfileState extends Equatable {
  final UserDetails? user;
  final List<PostModel> posts;
  const ProfileState({required this.user, required this.posts});

  const ProfileState.init()
      : user = null,
        posts = const [];

  ProfileState copyWith({UserDetails? user, List<PostModel>? posts}) {
    return ProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
    );
  }

  @override
  List<Object?> get props => [user, posts];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState.init()) {
    on<ProfileInitial>(_onInit);
    on<ProfileRefresh>(_onProfileRefresh);
    on<ProfilePostsRefresh>(_onPostsRefresh);
  }
  final _posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final _users = FirebaseFirestore.instance.collection(FBKeys.users);
  final storage = FirebaseStorage.instance;
  final AuthServices _auth = getIt();
  final postController = ScrollController();

  UserDetails? get user => _auth.user;

  _onInit(ProfileInitial event, Emitter<ProfileState> emit) {
    emit(state.copyWith(user: _auth.user));
    Future(_userStream);
    Future(_postsStream);
  }

  void _userStream() {
    _users.doc(_auth.user!.id).snapshots().listen((event) {
      if (isClosed) return;
      add(ProfileRefresh(UserDetails.fromJson(event.data()!)));
    });
  }

  void _postsStream() {
    final query = _posts.where('author', isEqualTo: user!.id);
    query.orderBy('date_time', descending: true).snapshots().listen((event) {
      if (isClosed) return;
      final posts = event.docs.map((e) => PostModel.fromJson(e.data()));
      if (posts.length == state.posts.length) return;
      add(ProfilePostsRefresh(posts.toList()));
    });
  }

  _onProfileRefresh(ProfileRefresh event, Emitter<ProfileState> emit) {
    if (event.user == _auth.user) return;
    emit(state.copyWith(user: event.user));
  }

  _onPostsRefresh(ProfilePostsRefresh event, Emitter<ProfileState> emit) {
    if (event.posts == state.posts) return;
    emit(state.copyWith(posts: event.posts ?? []));
  }
}
