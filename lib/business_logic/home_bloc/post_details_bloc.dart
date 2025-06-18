import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class PostDetailsEvent extends Equatable {
  const PostDetailsEvent();

  @override
  List<Object?> get props => [];
}

class PostDetailsInitial extends PostDetailsEvent {
  final String id;
  const PostDetailsInitial(this.id);

  @override
  List<Object?> get props => [...super.props, id];
}

class PostUserUnfriend extends PostDetailsEvent {
  final String id;
  const PostUserUnfriend(this.id);

  @override
  List<Object?> get props => [...super.props, id];
}

class PostAddFriend extends PostDetailsEvent {
  final String id;
  const PostAddFriend(this.id);

  @override
  List<Object?> get props => [...super.props, id];
}

class PostDetailsState extends Equatable {
  final UserDetails? profile;
  final bool success;
  const PostDetailsState({required this.profile, required this.success});

  const PostDetailsState.init()
      : profile = null,
        success = false;

  PostDetailsState copyWith({UserDetails? profile, bool? success}) {
    return PostDetailsState(
      profile: profile ?? this.profile,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [profile, success];
}

class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  PostDetailsBloc() : super(const PostDetailsState.init()) {
    on<PostDetailsInitial>(_onInit);
    on<PostAddFriend>(_onAddFriend);
    on<PostUserUnfriend>(_onUnfriend);
  }

  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final storage = FirebaseStorage.instance;

  void _onInit(PostDetailsInitial event, Emitter<PostDetailsState> emit) async {
    emit(const PostDetailsState.init());
    try {
      final _profile = await users.doc(event.id).get();
      final profile = UserDetails.fromJson(_profile.data()!);
      emit(state.copyWith(profile: profile));
    } catch (e) {
      logPrint(e, 'post details');
    }
  }

  void _onAddFriend(PostAddFriend event, Emitter<PostDetailsState> emit) {
    try {
      users.doc(event.id).update({
        'requests': FieldValue.arrayUnion([userId])
      });
      showToast('Friend request sent');
    } catch (e) {
      logPrint(e, 'Add Friend');
    } finally {
      emit(state.copyWith(success: true));
    }
  }

  void _onUnfriend(PostUserUnfriend event, Emitter<PostDetailsState> emit) {
    try {
      users.doc(userId).update({
        'friends': FieldValue.arrayRemove([event.id])
      });
      users.doc(event.id).update({
        'friends': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      logPrint(e, 'Unfriend');
    } finally {
      emit(state.copyWith(success: true));
    }
  }
}
