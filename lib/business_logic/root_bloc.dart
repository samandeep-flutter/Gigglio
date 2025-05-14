import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:gigglio/services/notification_services.dart';

class RootEvents extends Equatable {
  const RootEvents();

  @override
  List<Object?> get props => [];
}

class RootInitial extends RootEvents {}

class RootIndexChanged extends RootEvents {
  final int index;
  const RootIndexChanged(this.index);

  @override
  List<Object?> get props => [index, super.props];
}

class RootState extends Equatable {
  final int index;
  const RootState(this.index);

  const RootState.init() : index = 0;

  RootState copyWith({int? index}) {
    return RootState(index ?? this.index);
  }

  @override
  List<Object?> get props => [index];
}

class RootBloc extends Bloc<RootEvents, RootState> {
  RootBloc() : super(const RootState.init()) {
    on<RootInitial>(_rootInit);
    on<RootIndexChanged>(_rootIndexChanged);
  }

  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final AuthServices auth = getIt();
  late TabController tabController;

  void _rootInit(RootInitial event, Emitter<RootState> emit) async {
    Future(MyNotifications.initialize);
    await auth.getUserDetails();
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
