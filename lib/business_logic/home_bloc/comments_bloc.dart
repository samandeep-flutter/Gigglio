import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsEvent {
  final String postId;
  const CommentsInitial(this.postId);

  @override
  List<Object?> get props => [postId, ...super.props];
}

class CommentsGetUsers extends CommentsEvent {
  final List<CommentDbModel> comments;
  const CommentsGetUsers(this.comments);

  @override
  List<Object?> get props => [comments, ...super.props];
}

class AddComment extends CommentsEvent {
  final String postId;
  const AddComment(this.postId);

  @override
  List<Object?> get props => [postId, ...super.props];
}

class CommentsState extends Equatable {
  final bool loading;
  final List<CommentModel> comments;

  const CommentsState({required this.loading, required this.comments});

  const CommentsState.init()
      : loading = true,
        comments = const [];

  CommentsState copyWith({
    bool? loading,
    List<CommentModel>? comments,
  }) {
    return CommentsState(
      loading: loading ?? this.loading,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [loading, comments];
}

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc() : super(const CommentsState.init()) {
    on<CommentsInitial>(_onInit);
    on<CommentsGetUsers>(_onUsersFetch);
    on<AddComment>(_addComments);
  }

  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final commentsContr = TextEditingController();

  void _onInit(CommentsInitial event, Emitter<CommentsState> emit) async {
    emit(CommentsState.init());
    commentsContr.clear();
    try {
      final post = await posts.doc(event.postId).get();
      final postModel = PostDbModel.fromJson(post.data()!);
      add(CommentsGetUsers(postModel.comments));
    } catch (e) {
      logPrint(e, 'Comments init');
    }
  }

  void _onUsersFetch(
      CommentsGetUsers event, Emitter<CommentsState> emit) async {
    try {
      final List<CommentModel> comments = [];
      final _comments = List<CommentDbModel>.from(event.comments);
      _comments.removeWhere(
          (e) => state.comments.any((f) => f.dateTime == e.dateTime));
      for (CommentDbModel comment in _comments) {
        final user = await users.doc(comment.author).get();
        final author = UserDetails.fromJson(user.data()!);
        comments.add(CommentModel.fromDb(author, comment: comment));
      }
      emit(state.copyWith(comments: [...state.comments, ...comments]));
    } catch (e) {
      logPrint(e, 'Comment user');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void _addComments(AddComment event, Emitter<CommentsState> emit) async {
    final message = commentsContr.text.trim();
    commentsContr.clear();
    try {
      if (message.isEmpty) return;
      final comment = CommentDbModel(
          author: userId, title: message, dateTime: DateTime.now());
      showToast('posting...');
      await posts.doc(event.postId).update({
        'comments': FieldValue.arrayUnion([comment.toJson()])
      });
      final post = await posts.doc(event.postId).get();
      final postModel = PostDbModel.fromJson(post.data()!);
      add(CommentsGetUsers(postModel.comments));
      // TODO: integrate notification logic here
      // where if friends send notification to owner.

      // if (postAuthor.friends.contains(user.id)) {
      //   final noti = NotiModel(
      //     from: user.id,
      //     to: postAuthor.id,
      //     postId: doc,
      //     dateTime: DateTime.now().toJson(),
      //     category: NotiCategory.comment,
      //   );
      //   auth.sendNotification(noti);
      // }
    } catch (e) {
      logPrint(e, 'add Comments');
    }
  }
}
