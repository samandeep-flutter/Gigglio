import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileEvent {}

class ProfilePostsRefresh extends ProfileEvent {
  final List<PostModel>? posts;

  const ProfilePostsRefresh(this.posts);

  @override
  List<Object?> get props => [posts, ...super.props];
}

class ProfileState extends Equatable {
  final List<PostModel> posts;
  const ProfileState({required this.posts});

  const ProfileState.init() : posts = const [];

  ProfileState copyWith({List<PostModel>? posts}) {
    return ProfileState(
      posts: posts ?? this.posts,
    );
  }

  @override
  List<Object?> get props => [posts];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState.init()) {
    on<ProfileInitial>(_onInit);
    on<ProfilePostsRefresh>(_onPostsRefresh);
  }
  final _posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final storage = FirebaseStorage.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final postController = ScrollController();

  _onInit(ProfileInitial event, Emitter<ProfileState> emit) {
    Future(_postsStream);
  }

  void _postsStream() {
    final query = _posts.where('author', isEqualTo: userId);
    query.orderBy('date_time', descending: true).snapshots().listen((event) {
      if (isClosed) return;
      final posts = event.docs.map((e) => PostModel.fromJson(e.data()));
      if (posts.length == state.posts.length) return;
      add(ProfilePostsRefresh(posts.toList()));
    });
  }

  _onPostsRefresh(ProfilePostsRefresh event, Emitter<ProfileState> emit) {
    if (event.posts == state.posts) return;
    emit(state.copyWith(posts: event.posts ?? []));
  }
}
