import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../model/utils/app_constants.dart';
import '../../../model/utils/string.dart';
import '../../../services/auth_services.dart';

class SignInController extends GetxController {
  final AuthServices authServices = Get.find();
  final FirebaseAuth fbAuth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  RxBool signInLoading = RxBool(false);
  RxBool googleLoading = RxBool(false);
  RxBool twitterLoading = RxBool(false);

  void onSumbit() async {
    if (!(formKey.currentState?.validate() ?? true)) return;
    signInLoading.value = true;
    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      await authServices.saveCred(credentials);
      signInLoading.value = false;
      Get.offAllNamed(Routes.rootView);
    } on FirebaseAuthException catch (e) {
      signInLoading.value = false;
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'invalid-email') {
        showToast('Enter valid email address.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      }
    } catch (e) {
      signInLoading.value = false;
      logPrint('FbLogin: $e');
    }
  }

  void forgotPass() {}

  Future<void> googleSignin() async {
    googleLoading.value = true;
    try {
      final googleSignin = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await googleSignin.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      var credentials =
          await FirebaseAuth.instance.signInWithCredential(credential);
      await authServices.saveCred(credentials);
      googleLoading.value = false;
      Get.offAllNamed(Routes.rootView);
    } catch (e) {
      googleLoading.value = false;
      logPrint('GoogleLogin: $e');
    }
  }

  Future<void> twitterLogin() async {
    twitterLoading.value = true;
    try {
      TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      final credentials =
          await FirebaseAuth.instance.signInWithProvider(twitterProvider);
      await authServices.saveCred(credentials);
      twitterLoading.value = false;
      Get.offAllNamed(Routes.rootView);
    } on FirebaseAuthException catch (e) {
      twitterLoading.value = false;
      if (e.code == 'user-disabled') {
        showToast('The user account is disabled,'
            ' kindly try a different login method.');
      }
    } catch (e) {
      twitterLoading.value = false;
      logPrint('TwitterLogin: $e');
    }
  }
}
