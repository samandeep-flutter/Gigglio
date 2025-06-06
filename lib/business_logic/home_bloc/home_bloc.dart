import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeEvent {}

class HomePostsFetch extends HomeEvent {
  final List<PostDbModel> posts;
  const HomePostsFetch(this.posts);

  @override
  List<Object?> get props => [posts, ...super.props];
}

class HomeNotiRefresh extends HomeEvent {
  final Map<String, dynamic>? noti;
  const HomeNotiRefresh({required this.noti});

  @override
  List<Object?> get props => [noti, ...super.props];
}

class HomeRefresh extends HomeEvent {
  final bool loading;
  const HomeRefresh({this.loading = true});

  @override
  List<Object?> get props => [loading, ...super.props];
}

class HomeState extends Equatable {
  final bool loading;
  final DateTime? notiFetch;
  final List<PostModel> posts;

  const HomeState({
    required this.loading,
    required this.notiFetch,
    required this.posts,
  });

  const HomeState.init()
      : loading = false,
        posts = const [],
        notiFetch = null;

  HomeState copyWith(
      {bool? loading, DateTime? notiFetch, List<PostModel>? posts}) {
    return HomeState(
      loading: loading ?? this.loading,
      notiFetch: notiFetch ?? this.notiFetch,
      posts: posts ?? this.posts,
    );
  }

  @override
  List<Object?> get props => [loading, notiFetch, posts];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState.init()) {
    on<HomeInitial>(_onInit);
    on<HomePostsFetch>(_onPostsFetch);
    on<HomeNotiRefresh>(_onNotiRefresh);
    on<HomeRefresh>(_onRefresh);
  }
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final noti = FirebaseFirestore.instance.collection(FBKeys.noti);

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final storage = FirebaseStorage.instance;

  void _notiStream() {
    noti.where('to', isEqualTo: userId).snapshots().listen((event) {
      try {
        if (isClosed || event.docs.isEmpty) return;
        add(HomeNotiRefresh(noti: event.docs.first.data()));
      } catch (_) {}
    });
  }

  _onNotiRefresh(HomeNotiRefresh event, Emitter<HomeState> emit) {
    final date = event.noti?['date_time'] ?? '';
    emit(state.copyWith(notiFetch: DateTime.tryParse(date)));
  }

  void _onInit(HomeInitial event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      _notiStream();
      final query = this.posts.where('author', isNotEqualTo: userId);
      final page = query.orderBy('author');
      final snap = await page.orderBy('date_time', descending: true).get();
      final posts = snap.docs.map((e) {
        final post = PostDbModel.fromJson(e.data());
        return post.copyWith(id: e.id);
      }).toList();
      add(HomePostsFetch(posts));
    } catch (e) {
      logPrint(e, 'Home');
    }
  }

  void _onRefresh(HomeRefresh event, Emitter<HomeState> emit) {
    if (event.loading) emit(state.copyWith(loading: true));
    add(HomeInitial());
  }

  void _onPostsFetch(HomePostsFetch event, Emitter<HomeState> emit) async {
    final _posts = List<PostDbModel>.from(event.posts);
    try {
      final List<PostModel> posts = [];
      for (PostDbModel post in _posts) {
        final _user = await users.doc(post.author).get();
        final author = UserDetails.fromJson(_user.data()!);
        posts.add(PostModel.fromDb(user: author, post: post));
      }
      emit(state.copyWith(loading: false, posts: posts));
    } catch (e) {
      logPrint(e, 'Home');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }
}
