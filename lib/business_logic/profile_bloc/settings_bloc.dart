import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/services/getit_instance.dart';
import '../../data/utils/app_constants.dart';
import '../../services/auth_services.dart';

class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PasswordChanged extends SettingsEvent {}

class SettingsState extends Equatable {
  final bool changePassLoading;
  final String? error;
  const SettingsState({required this.changePassLoading, required this.error});

  const SettingsState.init()
      : changePassLoading = false,
        error = null;

  SettingsState copyWith({bool? changePassLoading, String? error}) {
    return SettingsState(
      changePassLoading: changePassLoading ?? this.changePassLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [changePassLoading, error];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState.init()) {
    on<PasswordChanged>(_onPassChanged);
  }

  final AuthServices auth = getIt();
  final _user = FirebaseAuth.instance.currentUser;

  final changePassKey = GlobalKey<FormState>();
  final oldPassContr = TextEditingController();
  final newPassContr = TextEditingController();
  final confirmPassContr = TextEditingController();

  void fromChangePass(bool canPop, _) => changePassKey.currentState?.reset();

  void _onPassChanged(
      PasswordChanged event, Emitter<SettingsState> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(changePassKey.currentState?.validate() ?? false)) return;
    emit(state.copyWith(changePassLoading: true));
    try {
      await _user!.updatePassword(confirmPassContr.text);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(error: e.code));
      logPrint(e, 'ChangePass');
    } catch (e) {
      logPrint(e, 'ChangePass');
    } finally {
      emit(state.copyWith(changePassLoading: false));
    }
  }
}
