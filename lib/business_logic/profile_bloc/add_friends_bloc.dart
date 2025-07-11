import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/data/utils/utils.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/services/getit_instance.dart';

class AddFriendsEvent extends Equatable {
  const AddFriendsEvent();

  @override
  List<Object?> get props => [];
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

class SearchFriends extends AddFriendsEvent {}

class SearchFriendsTrigger extends AddFriendsEvent {}

class AddFriendsState extends Equatable {
  final bool isLoading;
  final List<String> requested;
  final List<UserDetails> users;
  const AddFriendsState({
    required this.isLoading,
    required this.requested,
    required this.users,
  });

  const AddFriendsState.init()
      : isLoading = false,
        users = const [],
        requested = const [];

  AddFriendsState copyWith({
    bool? isLoading,
    List<String>? requested,
    List<UserDetails>? users,
  }) {
    return AddFriendsState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      requested: requested ?? this.requested,
    );
  }

  @override
  List<Object?> get props => [isLoading, requested, users];
}

class AddFriendsBloc extends Bloc<AddFriendsEvent, AddFriendsState> {
  AddFriendsBloc() : super(const AddFriendsState.init()) {
    on<AddFriendsInitial>(_onInit);
    on<SearchFriends>(_onSearch);
    on<SearchFriendsTrigger>(_onSearchTrigger,
        transformer: Utils.debounce(Durations.long4));
    on<AddFriendRequest>(_onRequest);
    on<RemoveAddedRFriend>(_onRemove);
  }

  final AuthServices auth = getIt();
  final uid = BoxServices.instance.uid;

  final users = FirebaseFirestore.instance.collection(FBKeys.users);

  final friendContr = TextEditingController();
  List<UserDetails> _friends = [];

  void _onInit(AddFriendsInitial event, Emitter<AddFriendsState> emit) async {
    friendContr.addListener(_listener);
    emit(state.copyWith(isLoading: true));
    try {
      final query = await users.where('friends', arrayContains: uid!).get();
      final _friends = query.docs.map((e) => UserDetails.fromJson(e.data()));
      this._friends = _friends.toList();
      emit(state.copyWith(users: _friends.toList()));
    } catch (e) {
      logPrint(e, 'onInit');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _listener() => add(SearchFriends());

  void _onSearch(SearchFriends event, Emitter<AddFriendsState> emit) {
    emit(state.copyWith(isLoading: true));
    add(SearchFriendsTrigger());
  }

  void _onSearchTrigger(
      SearchFriendsTrigger event, Emitter<AddFriendsState> emit) async {
    final query = friendContr.text.trim().toLowerCase();

    try {
      if (query.isEmpty) throw const FormatException();
      final filter = Filter.or(
          Filter.and(
            Filter('display_name', isGreaterThanOrEqualTo: query),
            Filter('display_name', isLessThanOrEqualTo: '$query\uf8ff'),
          ),
          Filter.and(Filter('email', isGreaterThanOrEqualTo: query),
              Filter('email', isLessThanOrEqualTo: '$query\uf8ff')));
      final _query = await this.users.where(filter).get();
      final users = _query.docs.map((e) => UserDetails.fromJson(e.data()));
      final _users = users.toList()..removeWhere((e) => e.id == uid!);
      emit(state.copyWith(users: _users));
    } on FormatException {
      emit(state.copyWith(users: _friends));
    } catch (e) {
      logPrint(e, 'search');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onRequest(AddFriendRequest event, Emitter<AddFriendsState> emit) async {
    try {
      users.doc(event.id).update({
        'requests': FieldValue.arrayUnion([uid!])
      });
      emit(state.copyWith(requested: [...state.requested, event.id]));
      final noti = NotiDbModel(
        from: uid!,
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
        'friends': FieldValue.arrayRemove([uid!])
      });
      users.doc(uid!).update({
        'friends': FieldValue.arrayRemove([event.id])
      });
    } catch (e) {
      logPrint(e, 'onRemove');
    }
  }
}
