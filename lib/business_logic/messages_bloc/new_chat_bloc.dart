import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';

class NewChatEvent extends Equatable {
  const NewChatEvent();

  @override
  List<Object> get props => [];
}

class NewChatInitial extends NewChatEvent {}

class NewChatSearch extends NewChatEvent {}

class NewChatState extends Equatable {
  final bool isLoading;
  final List<UserDetails> users;

  const NewChatState({required this.isLoading, required this.users});

  const NewChatState.init()
      : isLoading = true,
        users = const [];

  NewChatState copyWith({bool? isLoading, List<UserDetails>? users}) {
    return NewChatState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
    );
  }

  @override
  List<Object> get props => [isLoading, users];
}

class NewChatBloc extends Bloc<NewChatEvent, NewChatState> {
  NewChatBloc() : super(const NewChatState.init()) {
    on<NewChatInitial>(_onInit);
    on<NewChatSearch>(_onSearch);
  }

  final AuthServices auth = getIt();
  final users = FirebaseFirestore.instance.collection(FBKeys.users);

  final newChatContr = TextEditingController();

  List<UserDetails> _users = [];

  _onInit(NewChatInitial event, Emitter<NewChatState> emit) async {
    newChatContr.addListener(_lisntner);
    try {
      final id = auth.user!.id;
      final users = await this.users.where('friends', arrayContains: id).get();
      final _users = users.docs.map((e) => UserDetails.fromJson(e.data()));
      this._users = _users.toList();
      emit(state.copyWith(users: _users.toList()));
    } catch (e) {
      logPrint(e, 'NewChat');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _lisntner() => add(NewChatSearch());

  _onSearch(NewChatSearch event, Emitter<NewChatState> emit) async {
    final query = newChatContr.text.trim();
    try {
      final users = _users.where((e) {
        final email = e.email.split('@').first;
        final name = e.displayName.contains(query);
        return email.contains(query) || name;
      }).toList();
      emit(state.copyWith(users: users));
    } catch (e) {
      logPrint(e, 'search');
    }
  }
}
