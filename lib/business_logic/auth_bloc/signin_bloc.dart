import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/utils/app_constants.dart';

class SignInEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInInitial extends SignInEvents {}

class SignInviaEmail extends SignInEvents {}

class SignInviaGoogle extends SignInEvents {}

class SignInviaTwitter extends SignInEvents {}

class SignInState extends Equatable {
  final bool emailLoading;
  final bool googleLoading;
  final bool twitterLoading;
  final bool success;

  const SignInState(
      {required this.emailLoading,
      required this.googleLoading,
      required this.twitterLoading,
      required this.success});

  const SignInState.init()
      : emailLoading = false,
        googleLoading = false,
        twitterLoading = false,
        success = false;

  SignInState copyWith(
      {bool? emailLoading,
      bool? googleLoading,
      bool? twitterLoading,
      bool? success}) {
    return SignInState(
      emailLoading: emailLoading ?? this.emailLoading,
      googleLoading: googleLoading ?? this.googleLoading,
      twitterLoading: twitterLoading ?? this.twitterLoading,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props =>
      [emailLoading, googleLoading, twitterLoading, success];
}

class SignInBloc extends Bloc<SignInEvents, SignInState> {
  SignInBloc() : super(const SignInState.init()) {
    on<SignInInitial>(_onInit);
    on<SignInviaEmail>(_emailSignin);
    on<SignInviaGoogle>(_googleSignin);
    on<SignInviaTwitter>(_twitterSignin);
  }

  final fbAuth = FirebaseAuth.instance;
  final fbMessaging = FirebaseMessaging.instance;
  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final box = BoxServices.instance;
  final AuthServices auth = getIt();

  final formKey = GlobalKey<FormState>();
  final emailContr = TextEditingController();
  final passwordContr = TextEditingController();

  String? token;

  _onInit(SignInInitial event, Emitter<SignInState> emit) {
    if (kDebugMode) _loadDebug();
    Future(_getTokken);
  }

  void _loadDebug() {
    emailContr.text = 'morh@yopmail.com';
    passwordContr.text = 'Admin@123';
  }

  Future<void> _getTokken() async {
    try {
      await fbMessaging.requestPermission(provisional: true);
      token = await fbMessaging.getToken();
    } catch (e) {
      logPrint(e, 'Token');
    }
  }

  _emailSignin(SignInviaEmail event, Emitter<SignInState> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? true)) return;
    emit(state.copyWith(emailLoading: true));
    try {
      final credentials = await fbAuth.signInWithEmailAndPassword(
          email: emailContr.text, password: passwordContr.text);
      await fetchFbUser(credentials, token: token);
      emit(state.copyWith(success: true));
    } on FirebaseAuthException catch (e) {
      onFbSignInException(e);
    } catch (e) {
      logPrint(e, 'FbLogin');
    } finally {
      emit(state.copyWith(emailLoading: false));
    }
  }

  _googleSignin(SignInviaGoogle event, Emitter<SignInState> emit) async {
    formKey.currentState?.reset();
    emit(state.copyWith(googleLoading: true));
    try {
      final google = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await google.signIn();
      if (googleUser == null) throw Exception();
      final googleAuth = await googleUser.authentication;
      final oAuth = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final credentials = await fbAuth.signInWithCredential(oAuth);
      await fetchFbUser(credentials, token: token);
      emit(state.copyWith(success: true));
    } catch (e) {
      logPrint(e, 'Google');
    } finally {
      emit(state.copyWith(googleLoading: false));
    }
  }

  _twitterSignin(SignInviaTwitter event, Emitter<SignInState> emit) async {
    formKey.currentState?.reset();
    emit(state.copyWith(twitterLoading: true));
    try {
      TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      final credentials = await fbAuth.signInWithProvider(twitterProvider);
      await fetchFbUser(credentials, token: token);
      emit(state.copyWith(success: true));
    } on FirebaseAuthException catch (e) {
      onFbSignInException(e);
    } catch (e) {
      logPrint(e, 'Twitter');
    } finally {
      emit(state.copyWith(twitterLoading: false));
    }
  }

  Future<void> fetchFbUser(UserCredential credentials, {String? token}) async {
    final user = credentials.user;
    if (user == null) return;
    try {
      final json = await users.doc(user.uid).get();
      if (!json.exists) throw Exception();
      final _user = UserDetails.fromJson(json.data()!);
      users.doc(user.uid).update({'login': true});
      if (_user.deviceToken != token) {
        users.doc(user.uid).update({'device_token': token});
      }
    } catch (_) {
      var details = UserDetails(
        id: user.uid,
        displayName: user.displayName ?? '',
        email: user.email!,
        image: user.photoURL,
        notiSeen: DateTime.now(),
        deviceToken: token,
        login: true,
      );
      await users.doc(details.id).set(details.toJson());
    }
    box.write(BoxKeys.uid, credentials.user!.uid);
  }

  void onFbSignInException(FirebaseAuthException e) {
    logPrint(e, 'FbAuth');
    switch (e.code) {
      case 'invalid-credential':
        showToast('Incorrect Email or Passowrd.', timeInSec: 5);
        break;
      case 'user-disabled':
        showToast(
            'The user account is disabled,'
            ' kindly try a different login method.',
            timeInSec: 5);
        break;
      case 'network-request-failed':
        showToast('Check network connection', timeInSec: 5);
        break;
      default:
        showToast(e.message ?? 'Something went wrong, try again');
    }
  }
}
