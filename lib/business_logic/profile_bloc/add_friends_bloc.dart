import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:rxdart/rxdart.dart';

class AddFriendsEvent extends Equatable {
  const AddFriendsEvent();

  @override
  List<Object?> get props => [];
}

class AddFriendsRetrieve extends AddFriendsEvent {
  final List<UserDetails> users;
  const AddFriendsRetrieve(this.users);

  @override
  List<Object?> get props => [users, ...super.props];
}

class AddFriendRequest extends AddFriendsEvent {
  final String id;
  const AddFriendRequest(this.id);

  @override
  List<Object?> get props => [id, ...super.props];
}

class RemoveAddedRFriend extends AddFriendsEvent {
  final String id;
  const RemoveAddedRFriend(this.id);

  @override
  List<Object?> get props => [id, ...super.props];
}

class AddFriendsInitial extends AddFriendsEvent {}

class SearchFriends extends AddFriendsEvent {
  final String query;
  const SearchFriends(this.query);

  @override
  List<Object?> get props => [query, ...super.props];
}

class AddFriendsState extends Equatable {
  final String query;
  final UserDetails? profile;
  final int requests;
  final List<String> requested;
  final List<UserDetails> users;
  const AddFriendsState({
    required this.query,
    required this.profile,
    required this.requested,
    required this.users,
    required this.requests,
  });

  const AddFriendsState.init()
      : users = const [],
        requested = const [],
        query = '',
        profile = null,
        requests = 0;

  AddFriendsState copyWith({
    String? query,
    UserDetails? profile,
    List<String>? requested,
    List<UserDetails>? users,
    int? requests,
  }) {
    return AddFriendsState(
      query: query ?? this.query,
      users: users ?? this.users,
      requested: requested ?? this.requested,
      profile: profile ?? this.profile,
      requests: requests ?? this.requests,
    );
  }

  @override
  List<Object?> get props => [query, profile, requests, requested, users];
}

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class AddFriendsBloc extends Bloc<AddFriendsEvent, AddFriendsState> {
  AddFriendsBloc() : super(AddFriendsState.init()) {
    on<SearchFriends>(_onSearch, transformer: _debounce(duration));
    on<AddFriendsInitial>(_onInit);
    on<AddFriendsRetrieve>(_onRetrieve);
    on<AddFriendRequest>(_onRequest);
    on<RemoveAddedRFriend>(_onRemove);
  }

  final AuthServices auth = getIt();
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final duration = const Duration(milliseconds: 400);

  StreamSubscription? _stream;
  final friendContr = TextEditingController();
  List<UserDetails> _allUsers = [];

  void _onInit(AddFriendsInitial event, Emitter<AddFriendsState> emit) {
    friendContr.addListener(onSearch);
    friendContr.clear();
    _allUsers.clear();
    _getUsers();
  }

  void onPop(bool result, [dynamic]) {
    friendContr.removeListener(onSearch);
  }

  Future<void> _getUsers() async {
    _stream = users.snapshots().listen((snapshot) {
      if (isClosed) _stream?.cancel();
      final users = snapshot.docs.map((e) {
        return UserDetails.fromJson(e.data());
      }).toList();
      add(AddFriendsRetrieve(users));
    });
  }

  void _onSearch(SearchFriends event, Emitter<AddFriendsState> emit) async {
    final query = event.query.trim();
    try {
      List<UserDetails> searched = _allUsers.where((e) {
        final email = e.email.split('@').first;
        final name = e.displayName.contains(query);
        return email.contains(query) || name;
      }).toList();
      if (query.isEmpty) {
        final friends = state.profile?.friends ?? [];
        searched = _allUsers.where((e) => friends.contains(e.id)).toList();
      }
      emit(state.copyWith(users: searched, query: query));
    } catch (e) {
      logPrint(e, 'search');
    }
  }

  void _onRetrieve(AddFriendsRetrieve event, Emitter<AddFriendsState> emit) {
    try {
      final cUser = event.users.firstWhere((e) => e.id == auth.user!.id);
      _allUsers = event.users.where((e) => e.id != auth.user!.id).toList();
      final _req = _allUsers.where((e) => e.requests.contains(auth.user!.id));
      final ids = _req.map((e) => e.id).toList();
      final requests = cUser.requests.length;
      emit(state.copyWith(requests: requests, profile: cUser, requested: ids));
      if (state.query.isEmpty) {
        final users = event.users.where((e) => cUser.friends.contains(e.id));
        emit(state.copyWith(users: users.toList()));
      }
    } catch (e) {
      logPrint(e, 'retrieve');
    }
  }

  void onSearch() {
    if (isClosed) return;
    add(SearchFriends(friendContr.text));
  }

  void _onRequest(AddFriendRequest event, Emitter<AddFriendsState> emit) async {
    try {
      await users.doc(event.id).update({
        'requests': FieldValue.arrayUnion([auth.user!.id])
      });
      final noti = NotiDbModel(
        from: auth.user!.id,
        to: event.id,
        dateTime: DateTime.now(),
        category: NotiCategory.request,
      );
      auth.sendNotification(noti);
    } catch (e) {
      logPrint(e, 'onRequest');
    }
  }

  _onRemove(RemoveAddedRFriend event, Emitter<AddFriendsState> emit) async {
    try {
      users.doc(event.id).update({
        'friends': FieldValue.arrayRemove([auth.user!.id])
      });
      users.doc(auth.user!.id).update({
        'friends': FieldValue.arrayRemove([event.id])
      });
    } catch (e) {
      logPrint(e, 'onRemove');
    }
  }
}
