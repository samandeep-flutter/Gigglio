import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:rxdart/rxdart.dart';

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

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationState.init()) {
    on<NotificationInitial>(_onInit);
    on<NotiReqAccepted>(_onReqAccepted);
    on<NotiUserFetch>(_onUserFetch, transformer: _debounce(Durations.medium1));
  }

  final noti = FirebaseFirestore.instance.collection(FBKeys.noti);
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final AuthServices auth = getIt();

  void _onInit(
      NotificationInitial event, Emitter<NotificationState> emit) async {
    try {
      users.doc(auth.user!.id).get().then((snap) {
        final profile = UserDetails.fromJson(snap.data()!);
        emit(state.copyWith(profile: profile));
      });
      final _query = this.noti.where('to', isEqualTo: auth.user!.id);
      final query = _query.orderBy('to').limit(10);
      final snap = await query.orderBy('date_time', descending: true).get();
      final noti = snap.docs.map((e) => NotiDbModel.fromJson(e.data()));
      if (noti.isEmpty) throw Exception();
      add(NotiUserFetch(noti.toList()));
      _saveCount();
    } catch (e) {
      logPrint(e, 'Notification');
      emit(state.copyWith(loading: false));
    }
  }

  _onUserFetch(NotiUserFetch event, Emitter<NotificationState> emit) async {
    final List<NotiModel> notifications = [];
    final user = Completer<UserDetails>();
    final post = Completer<PostModel?>();
    try {
      for (final noti in event.notifications) {
        users.doc(noti.from).get().then((json) {
          user.complete(UserDetails.fromJson(json.data()!));
        });
        try {
          if (noti.postId == null) throw Exception();
          posts.doc(noti.postId!).get().then((json) {
            post.complete(PostModel.fromJson(json.data()!));
          });
        } catch (_) {
          post.complete(null);
        }

        final _user = await user.future;
        final _post = await post.future;
        notifications.add(NotiModel(
          from: _user,
          to: noti.to,
          post: _post,
          dateTime: noti.dateTime,
          category: noti.category,
        ));
      }
      emit(state.copyWith(notifications: notifications));
    } catch (e) {
      logPrint(e, 'onUserFetch');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void _saveCount() {
    final doc = users.doc(auth.user!.id);
    final date = DateTime.now().toIso8601String();
    doc.update({'noti_seen': date});
  }

  _onReqAccepted(NotiReqAccepted event, Emitter<NotificationState> emit) async {
    try {
      users.doc(event.id).update({
        'friends': FieldValue.arrayUnion([auth.user!.id])
      });
      await users.doc(auth.user!.id).update({
        'requests': FieldValue.arrayRemove([event.id]),
        'friends': FieldValue.arrayUnion([event.id])
      });
      users.doc(auth.user!.id).get().then((snap) {
        final profile = UserDetails.fromJson(snap.data()!);
        emit(state.copyWith(profile: profile));
      });

      final noti = NotiDbModel(
        from: auth.user!.id,
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
