import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class ForgotPassEvents extends Equatable {
  const ForgotPassEvents();

  @override
  List<Object?> get props => [];
}

class ForgotPassLinkSend extends ForgotPassEvents {}

class ForgotPassState extends Equatable {
  final bool loading;
  final bool linkSent;

  const ForgotPassState({required this.loading, required this.linkSent});

  const ForgotPassState.init()
      : loading = false,
        linkSent = false;

  ForgotPassState copyWith({bool? loading, bool? linkSent}) {
    return ForgotPassState(
        loading: loading ?? this.loading, linkSent: linkSent ?? this.linkSent);
  }

  @override
  List<Object?> get props => [loading, linkSent];
}

class ForgotPassBloc extends Bloc<ForgotPassEvents, ForgotPassState> {
  ForgotPassBloc() : super(const ForgotPassState.init()) {
    on<ForgotPassLinkSend>(_onLinkSent);
  }

  final fbAuth = FirebaseAuth.instance;

  final forgotPassContr = TextEditingController();
  final forgotPassKey = GlobalKey<FormFieldState>();

  void fromForgotPass(bool didPop, _) => forgotPassKey.currentState?.reset();

  void _onLinkSent(
      ForgotPassLinkSend event, Emitter<ForgotPassState> emit) async {
    if (!(forgotPassKey.currentState?.validate() ?? false)) return;
    emit(state.copyWith(loading: true));
    try {
      await fbAuth.sendPasswordResetEmail(email: forgotPassContr.text);
      emit(state.copyWith(linkSent: true));
    } on FirebaseAuthException catch (e) {
      onFbException(e);
    } catch (e) {
      logPrint(e, 'ForgotPass');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void onFbException(FirebaseAuthException e) {
    logPrint(e, 'FbAuth');

    switch (e.code) {
      case 'invalid-email':
        showToast('the email address is not valid');
        break;
      case 'user-not-found':
        showToast('Incorrect Email or Passowrd.', timeInSec: 5);
        break;
    }
  }
}
