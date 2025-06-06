import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import '../../data/utils/string.dart';

class SignUpEvents extends Equatable {
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
  final fbAuth = FirebaseAuth.instance;
  final fbMessaging = FirebaseMessaging.instance;
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final AuthServices auth = getIt();

  final formKey = GlobalKey<FormState>();
  final nameContr = TextEditingController();
  final emailContr = TextEditingController();
  final passContr = TextEditingController();
  final confirmPassContr = TextEditingController();

  String? token;

  _onInit(SignupInitial event, Emitter<SignupState> emit) {
    if (kDebugMode) _loadDebug();
    Future(_getTokken);
  }

  Future<void> _getTokken() async {
    try {
      await fbMessaging.requestPermission(provisional: true);
      token = await fbMessaging.getToken();
    } catch (e) {
      logPrint(e, 'Token');
    }
  }

  void _loadDebug() {
    nameContr.text = 'Checkqa';
    emailContr.text = 'checkqa@yopmail.com';
    confirmPassContr.text = passContr.text = 'Admin@123';
  }

  _onSignUp(SignUpviaEmail event, Emitter<SignupState> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    emit(state.copyWith(loading: true));
    try {
      final credentials = await fbAuth.createUserWithEmailAndPassword(
          email: emailContr.text, password: confirmPassContr.text);
      await fbAuth.currentUser?.updateDisplayName(nameContr.text);
      await createFbUser(credentials, name: nameContr.text, token: token);
      emit(state.copyWith(success: true));
    } on FirebaseAuthException catch (e) {
      onFbSignUpException(e);
    } catch (e) {
      logPrint(e, 'FbLogin');
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> createFbUser(UserCredential credentials,
      {required String name, String? token}) async {
    if (credentials.user == null) return;
    try {
      var details = UserDetails(
        id: credentials.user!.uid,
        displayName: name,
        email: credentials.user!.email!,
        image: credentials.user?.photoURL,
        notiSeen: DateTime.now(),
        deviceToken: token,
        login: true,
      );
      await users.doc(details.id).set(details.toJson());
    } catch (e) {
      logPrint(e, 'createFbUser');
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
      case 'network-request-failed':
        showToast('Check network connection', timeInSec: 5);
        break;
      default:
        showToast(e.message ?? StringRes.errorUnknown);
    }
  }
}
