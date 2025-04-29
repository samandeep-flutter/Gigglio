import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import '../data/models/notification_model.dart';

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

  void onTabChanged(int index) => add(RootIndexChanged(index));

  void _rootInit(RootInitial event, Emitter<RootState> emit) async {
    await authServices.getUserDetails();
  }

  void _rootIndexChanged(RootIndexChanged event, Emitter<RootState> emit) {
    tabController.animateTo(event.index);
    emit(state.copyWith(index: event.index));
  }

  final AuthServices authServices = getIt();
  final users = FirebaseFirestore.instance.collection(FB.users);
  final noti = FirebaseFirestore.instance.collection(FB.noti);

  late TabController tabController;

  final List<BottomNavigationBarItem> tabList = [
    const BottomNavigationBarItem(
      label: StringRes.home,
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
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

  void sendRequest(String id) {
    final userId = authServices.user!.id;
    final doc = users.doc(id);
    doc.update({
      'requests': FieldValue.arrayUnion([userId])
    });
    final noti = NotiModel(
      from: userId,
      to: id,
      postId: null,
      dateTime: DateTime.now().toJson(),
      category: NotiCategory.request,
    );
    this.noti.add(noti.toJson());
  }

  void acceptRequest(String id, {int? index}) async {
    final userId = authServices.user!.id;
    final otherUser = users.doc(id);
    final myUser = users.doc(userId);
    await otherUser.update({
      'friends': FieldValue.arrayUnion([userId]),
    });
    await myUser.update({
      'friends': FieldValue.arrayUnion([id]),
      'requests': FieldValue.arrayRemove([id]),
    });
    if (index != null) {
      // Get.find<ProfileController>().reqAccepted[index] = true;
    }
  }
}
