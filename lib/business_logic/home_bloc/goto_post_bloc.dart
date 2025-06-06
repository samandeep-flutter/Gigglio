import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class GoToPostEvent extends Equatable {
  const GoToPostEvent();

  @override
  List<Object?> get props => [];
}

class GotoPostInitial extends GoToPostEvent {
  final String postId;
  const GotoPostInitial(this.postId);

  @override
  List<Object?> get props => [postId, ...super.props];
}

class GoToUserPost extends GoToPostEvent {
  final PostDbModel post;
  const GoToUserPost(this.post);

  @override
  List<Object?> get props => [post, ...super.props];
}

class GoToPostState extends Equatable {
  final bool loading;
  final PostModel? post;
  const GoToPostState({required this.loading, required this.post});

  const GoToPostState.init()
      : loading = true,
        post = null;

  GoToPostState copyWith({bool? loading, PostModel? post}) {
    return GoToPostState(
      loading: loading ?? this.loading,
      post: post ?? this.post,
    );
  }

  @override
  List<Object?> get props => [loading, post];
}

class GotoPostBloc extends Bloc<GoToPostEvent, GoToPostState> {
  GotoPostBloc() : super(const GoToPostState.init()) {
    on<GotoPostInitial>(_onInit);
    on<GoToUserPost>(_onUserPost);
  }
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final userId = FirebaseAuth.instance.currentUser!.uid;

  void _onInit(GotoPostInitial event, Emitter<GoToPostState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final _post = await posts.doc(event.postId).get();
      final post = PostDbModel.fromJson(_post.data()!);
      add(GoToUserPost(post.copyWith(id: _post.id)));
    } catch (e) {
      logPrint(e, 'Goto Post');
    }
  }

  void _onUserPost(GoToUserPost event, Emitter<GoToPostState> emit) async {
    try {
      final _user = await users.doc(event.post.author).get();
      final user = UserDetails.fromJson(_user.data()!);
      final post = PostModel.fromDb(user: user, post: event.post);
      emit(state.copyWith(post: post));
    } catch (e) {
      logPrint(e, 'Goto Post');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }
}
