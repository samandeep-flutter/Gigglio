import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/services/notification_services.dart';

class RootEvents extends Equatable {
  const RootEvents();

  @override
  List<Object?> get props => [];
}

class RootInitial extends RootEvents {}

class RootUserUpdate extends RootEvents {
  final UserDetails profile;
  const RootUserUpdate(this.profile);

  @override
  List<Object?> get props => [profile, super.props];
}

class RootPostLiked extends RootEvents {
  final String id;
  final bool? contains;
  const RootPostLiked(this.id, {this.contains});

  @override
  List<Object?> get props => [id, contains, super.props];
}

class RootIndexChanged extends RootEvents {
  final int index;
  const RootIndexChanged(this.index);

  @override
  List<Object?> get props => [index, super.props];
}

class RootState extends Equatable {
  final int index;
  final UserDetails? profile;
  final bool profileLoading;
  const RootState({
    required this.index,
    required this.profile,
    required this.profileLoading,
  });

  const RootState.init()
      : index = 0,
        profileLoading = true,
        profile = null;

  RootState copyWith({int? index, UserDetails? profile, bool? profileLoading}) {
    return RootState(
      index: index ?? this.index,
      profile: profile ?? this.profile,
      profileLoading: profileLoading ?? this.profileLoading,
    );
  }

  @override
  List<Object?> get props => [index, profile, profileLoading];
}

class RootBloc extends Bloc<RootEvents, RootState> {
  RootBloc() : super(const RootState.init()) {
    on<RootInitial>(_rootInit);
    on<RootPostLiked>(_onPostLiked);
    on<RootUserUpdate>(_onUpdate);
    on<RootIndexChanged>(_rootIndexChanged);
  }

  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final box = BoxServices.instance;

  final storage = FirebaseStorage.instance;
  late TabController tabController;

  void _rootInit(RootInitial event, Emitter<RootState> emit) async {
    emit(const RootState.init());
    Future(MyNotifications.initialize);
    users.doc(box.uid!).snapshots().listen((snap) {
      if (isClosed) return;
      final profile = UserDetails.fromJson(snap.data()!);
      add(RootUserUpdate(profile));
    }, onError: (e) => logPrint(e, 'root user'));
  }

  void _onUpdate(RootUserUpdate event, Emitter<RootState> emit) {
    emit(state.copyWith(profile: event.profile, profileLoading: false));
  }

  void _rootIndexChanged(RootIndexChanged event, Emitter<RootState> emit) {
    tabController.animateTo(event.index);
    emit(state.copyWith(index: event.index));
  }

  void _onPostLiked(RootPostLiked event, Emitter<RootState> emit) async {
    posts.doc(event.id).update({
      'likes': event.contains ?? false
          ? FieldValue.arrayRemove([box.uid!])
          : FieldValue.arrayUnion([box.uid!])
    });
  }

  final List<BottomNavigationBarItem> tabList = [
    const BottomNavigationBarItem(
      label: StringRes.home,
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
    ),
    const BottomNavigationBarItem(
      label: StringRes.addPost,
      icon: Icon(Icons.add_to_photos_outlined),
      activeIcon: Icon(Icons.add_to_photos),
    ),
    const BottomNavigationBarItem(
      label: StringRes.messages,
      icon: Icon(Icons.message_outlined),
      activeIcon: Icon(Icons.message),
    ),
    const BottomNavigationBarItem(
      label: StringRes.profile,
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
    ),
  ];
}
