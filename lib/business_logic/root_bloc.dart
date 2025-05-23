import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/string.dart';
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
    on<RootUserUpdate>(_onUpdate);
    on<RootIndexChanged>(_rootIndexChanged);
  }

  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late TabController tabController;

  Future<void> _updateUser() async {
    users.doc(userId).snapshots().listen((snap) {
      final profile = UserDetails.fromJson(snap.data()!);
      add(RootUserUpdate(profile));
    });
  }

  void _rootInit(RootInitial event, Emitter<RootState> emit) async {
    Future(MyNotifications.initialize);
    Future(_updateUser);
  }

  void _onUpdate(RootUserUpdate event, Emitter<RootState> emit) {
    emit(state.copyWith(profile: event.profile, profileLoading: false));
  }

  void _rootIndexChanged(RootIndexChanged event, Emitter<RootState> emit) {
    tabController.animateTo(event.index);
    emit(state.copyWith(index: event.index));
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
