import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import '../../data/utils/string.dart';

class SignUpEvents extends Equatable {
  const SignUpEvents();

  @override
  List<Object?> get props => [];
}

class SignupInitial extends SignUpEvents {}

class SignUpviaEmail extends SignUpEvents {}

class SignupState extends Equatable {
  final bool loading;
  final bool success;

  const SignupState({required this.loading, required this.success});

  const SignupState.init()
      : loading = false,
        success = false;

  SignupState copyWith({bool? loading, bool? success}) {
    return SignupState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [loading, success];
}

class SignUpBloc extends Bloc<SignUpEvents, SignupState> {
  SignUpBloc() : super(const SignupState.init()) {
    on<SignupInitial>(_onInit);
    on<SignUpviaEmail>(_onSignUp);
  }
  final AuthServices auth = getIt();
  final fbAuth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  _onInit(SignupInitial event, Emitter<SignupState> emit) {
    if (kDebugMode) _loadDebug();
  }

  void _loadDebug() {
    nameController.text = 'Checkqa';
    emailController.text = 'checkqa@yopmail.com';
    confirmPassController.text = passController.text = 'Admin@123';
  }

  _onSignUp(SignUpviaEmail event, Emitter<SignupState> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    emit(state.copyWith(loading: true));
    try {
      final credentials = await fbAuth.createUserWithEmailAndPassword(
          email: emailController.text, password: confirmPassController.text);
      await fbAuth.currentUser?.updateDisplayName(nameController.text);
      await auth.createFbUser(credentials, name: nameController.text);
      emit(state.copyWith(success: true));
    } on FirebaseAuthException catch (e) {
      onFbSignUpException(e);
    } catch (e) {
      logPrint(e, 'FbLogin');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  void onFbSignUpException(FirebaseAuthException e) {
    logPrint(e, 'FbAuth');
    switch (e.code) {
      case 'weak-password':
        showToast('The password provided is too weak.');
        break;
      case 'invalid-email':
        showToast('Enter valid email address.');
        break;
      case 'email-already-in-use':
        showToast('The account already exists for that email.');
        break;
      default:
        showToast(e.message ?? StringRes.errorUnknown);
    }
  }
}
