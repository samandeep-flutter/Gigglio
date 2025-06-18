import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';

class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationEvent {}

class NotiUserFetch extends NotificationEvent {
  final List<NotiDbModel> notifications;

  const NotiUserFetch(this.notifications);

  @override
  List<Object?> get props => [notifications, ...super.props];
}

class NotiReqAccepted extends NotificationEvent {
  final String id;
  const NotiReqAccepted(this.id);

  @override
  List<Object?> get props => [id, ...super.props];
}

class NotificationState extends Equatable {
  final bool loading;
  final UserDetails? profile;
  final List<NotiModel> notifications;
  const NotificationState(
      {required this.loading,
      required this.profile,
      required this.notifications});

  const NotificationState.init()
      : loading = true,
        profile = null,
        notifications = const [];

  NotificationState copyWith(
      {bool? loading, UserDetails? profile, List<NotiModel>? notifications}) {
    return NotificationState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [loading, profile, notifications];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState.init()) {
    on<NotificationInitial>(_onInit);
    on<NotiReqAccepted>(_onReqAccepted);
    on<NotiUserFetch>(_onUserFetch,
        transformer: Utils.debounce(Durations.medium1));
  }

  final noti = FirebaseFirestore.instance.collection(FBKeys.noti);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final AuthServices auth = getIt();

  void _onInit(
      NotificationInitial event, Emitter<NotificationState> emit) async {
    final profile = Completer<UserDetails>();
    try {
      users.doc(userId).get().then((snap) {
        final _profile = UserDetails.fromJson(snap.data()!);
        profile.complete(_profile);
      });
      final _query = this.noti.where('to', isEqualTo: userId);
      final query = _query.orderBy('to').limit(10);
      final snap = await query.orderBy('date_time', descending: true).get();
      final noti = snap.docs.map((e) => NotiDbModel.fromJson(e.data()));
      if (noti.isEmpty) throw Exception();
      add(NotiUserFetch(noti.toList()));
      final date = DateTime.now().toIso8601String();
      users.doc(userId).update({'noti_seen': date});
      final _profile = await profile.future;
      emit(state.copyWith(profile: _profile));
    } catch (e) {
      logPrint(e, 'Notification');
      emit(state.copyWith(loading: false));
    }
  }

  _onUserFetch(NotiUserFetch event, Emitter<NotificationState> emit) async {
    final List<NotiModel> notifications = [];
    try {
      for (final noti in event.notifications) {
        final user = Completer<UserDetails>();
        final post = Completer<PostDbModel?>();
        users.doc(noti.from).get().then((json) {
          user.complete(UserDetails.fromJson(json.data()!));
        });
        try {
          if (noti.postId == null) throw Exception();
          posts.doc(noti.postId!).get().then((json) {
            post.complete(PostDbModel.fromJson(json.data()!));
          });
        } catch (_) {
          post.complete(null);
        }

        final _user = await user.future;
        final _post = await post.future;
        notifications
            .add(NotiModel.fromDb(user: _user, post: _post, noti: noti));
      }
      emit(state.copyWith(notifications: notifications));
    } catch (e) {
      logPrint(e, 'onUserFetch');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  _onReqAccepted(NotiReqAccepted event, Emitter<NotificationState> emit) async {
    try {
      users.doc(event.id).update({
        'friends': FieldValue.arrayUnion([userId])
      });
      users.doc(userId).update({
        'requests': FieldValue.arrayRemove([event.id]),
        'friends': FieldValue.arrayUnion([event.id])
      });
      final friends = state.profile?.friends ?? [];
      final _profile = state.profile!.copyWith(friends: [...friends, event.id]);
      emit(state.copyWith(profile: _profile));

      final noti = NotiDbModel(
        from: userId,
        to: event.id,
        dateTime: DateTime.now(),
        category: NotiCategory.reqAccepted,
      );
      auth.sendNotification(noti);
    } catch (e) {
      logPrint(e, 'onReqAccepted');
    }
  }
}
