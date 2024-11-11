import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gigglio/view/widgets/top_widgets.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../model/utils/app_constants.dart';
import '../../../model/utils/string.dart';
import '../../../services/auth_services.dart';
import '../../../services/theme_services.dart';

class SignInController extends GetxController {
  final AuthServices authServices = Get.find();
  final FirebaseAuth fbAuth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final forgotPassContr = TextEditingController();
  final forgotPassKey = GlobalKey<FormFieldState>();

  RxBool signInLoading = RxBool(false);
  RxBool forgotPassLoading = RxBool(false);
  RxBool googleLoading = RxBool(false);
  RxBool twitterLoading = RxBool(false);

  void onSumbit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? true)) return;
    signInLoading.value = true;
    try {
      final credentials = await fbAuth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      await authServices.saveCred(credentials);
      signInLoading.value = false;
      Get.offAllNamed(Routes.rootView);
    } on FirebaseAuthException catch (e) {
      signInLoading.value = false;
      onFbSignInException(e);
    } catch (e) {
      signInLoading.value = false;
      logPrint('FbLogin: $e');
    }
  }

  void forgotPass() => Get.toNamed(Routes.forgotPass);

  void sendForgotPassLink() async {
    if (!(forgotPassKey.currentState?.validate() ?? false)) return;
    forgotPassLoading.value = true;
    try {
      // final acs = ActionCodeSettings(
      //     url: 'https://yopmail.com/en/wm',
      //     handleCodeInApp: true,
      //     iOSBundleId: StringRes.packageName,
      //     androidPackageName: StringRes.packageName,
      //     androidInstallApp: true,
      //     androidMinimumVersion: '1.0');
      await fbAuth.sendPasswordResetEmail(email: forgotPassContr.text);
      showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) {
            final scheme = ThemeServices.of(context);

            return MyAlertDialog(
              title: StringRes.success,
              content: Text(
                StringRes.forgotPassOKDesc,
                style: TextStyle(color: scheme.textColorLight),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.close(2),
                  child: const Text('OK'),
                )
              ],
            );
          });
    } on FirebaseAuthException catch (e) {
      onFbForgotPassException(e);
    } catch (e) {
      logPrint('ForgotPass: $e');
    } finally {
      forgotPassLoading.value = false;
    }
  }

  void fromForgotPass(bool didPop, result) =>
      forgotPassKey.currentState?.reset();

  Future<void> googleSignin() async {
    formKey.currentState?.reset();
    googleLoading.value = true;
    try {
      final googleSignin = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await googleSignin.signIn();
      if (googleUser == null) {
        googleLoading.value = false;
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      var credentials = await fbAuth.signInWithCredential(credential);
      await authServices.saveCred(credentials);
      googleLoading.value = false;
      Get.offAllNamed(Routes.rootView);
    } catch (e) {
      googleLoading.value = false;
      logPrint('Google: $e');
    }
  }

  Future<void> twitterLogin() async {
    formKey.currentState?.reset();
    twitterLoading.value = true;
    try {
      TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      final credentials = await fbAuth.signInWithProvider(twitterProvider);
      await authServices.saveCred(credentials);
      twitterLoading.value = false;
      Get.offAllNamed(Routes.rootView);
    } on FirebaseAuthException catch (e) {
      twitterLoading.value = false;
      onFbSignInException(e);
    } catch (e) {
      twitterLoading.value = false;
      logPrint('Twitter: $e');
    }
  }

  void onFbSignInException(FirebaseAuthException e) {
    logPrint('FbAuth: $e');
    switch (e.code) {
      case 'invalid-credential':
        showToast('Incorrect Email or Passowrd.', timeInSec: 5);
        break;
      case 'user-disabled':
        showToast('The user account is disabled,'
            ' kindly try a different login method.');
        break;
      default:
        showToast(e.message ?? 'Something went wrong, try again');
    }
  }

  void onFbForgotPassException(FirebaseAuthException e) {
    logPrint('FbAuth: $e');

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
