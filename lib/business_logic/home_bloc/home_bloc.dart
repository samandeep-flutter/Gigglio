import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeEvent {}

class HomeNotiRefresh extends HomeEvent {
  final Map<String, dynamic>? noti;
  HomeNotiRefresh({required this.noti});

  @override
  List<Object?> get props => [noti, ...super.props];
}

class HomeRefresh extends HomeEvent {
  final bool loading;
  HomeRefresh({this.loading = true});

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
    on<HomeNotiRefresh>(_onNotiRefresh);
    on<HomeRefresh>(_onRefresh);
  }
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final noti = FirebaseFirestore.instance.collection(FBKeys.noti);

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final storage = FirebaseStorage.instance;

  // final commentContr = TextEditingController();
  // final commentKey = GlobalKey<FormFieldState>();
  // final RxList<String> shareSel = RxList();
  // final RxBool shareLoading = RxBool(false);

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
        final post = PostModel.fromJson(e.data());
        return post.copyWith(id: e.id);
      }).toList();
      emit(state.copyWith(posts: posts));
    } catch (e) {
      logPrint(e, 'Home');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void _onRefresh(HomeRefresh event, Emitter<HomeState> emit) {
    if (event.loading) emit(state.copyWith(loading: true));
    add(HomeInitial());
  }

  // void likePost(String id, {required PostModel post}) async {
  //   posts.doc(id).update({
  //     'likes': post.likes.contains(auth.user!.id)
  //         ? FieldValue.arrayRemove([auth.user!.id])
  //         : FieldValue.arrayUnion([auth.user!.id]),
  //   });
  // }

  // void gotoProfile(String id) =>
  //     Get.toNamed(AppRoutes.gotoProfile, arguments: id);
  // void gotoPost(String id) => Get.toNamed(AppRoutes.gotoPost, arguments: id);

  // void postComment(String doc, {required UserDetails postAuthor}) async {
  //   if (!(commentKey.currentState?.validate() ?? false)) return;
  //   if (commentContr.text.isEmpty) return;
  //   final user = authServices.user!;
  //   final comment = CommentModel(
  //       author: user.id,
  //       title: commentContr.text,
  //       dateTime: DateTime.now().toJson());

  //   posts.doc(doc).update({
  //     'comments': FieldValue.arrayUnion([comment.toJson()])
  //   });
  //   commentKey.currentState?.reset();
  //   commentContr.clear();
  //   FocusManager.instance.primaryFocus?.unfocus();

  //   if (postAuthor.friends.contains(user.id)) {
  //     final noti = NotiModel(
  //       from: user.id,
  //       to: postAuthor.id,
  //       postId: doc,
  //       dateTime: DateTime.now().toJson(),
  //       category: NotiCategory.comment,
  //     );
  //     this.noti.add(noti.toJson());
  //   }
  // }

  // void sharePost(String postId) async {
  //   final userId = authServices.user!.id;
  //   shareLoading.value = true;
  //   final ref = await _messages.where('users', arrayContains: userId).get();
  //   final List docs = [];
  //   for (var e in ref.docs) {
  //     final users = e.data()['users'] as List;
  //     users.removeWhere((e) => e == userId);
  //     docs.addIf(shareSel.contains(users.first), e.id);
  //   }
  //   for (var id in docs) {
  //     final doc = _messages.doc(id);
  //     await doc.get().then((e) {
  //       final text = '${AppConstants.appUrl}/$postId';
  //       final position = (e.data()!['messages'] as List).length;
  //       final message = Messages(
  //           author: userId,
  //           dateTime: DateTime.now().toJson(),
  //           text: text,
  //           scrollAt: null,
  //           position: position + 1);
  //       doc.update({
  //         'messages': FieldValue.arrayUnion([message.toJson()])
  //       });
  //     });
  //   }
  //   shareLoading.value = false;
  //   Get.back();
  // }
}
