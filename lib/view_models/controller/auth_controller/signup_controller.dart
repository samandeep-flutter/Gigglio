import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import '../../../model/utils/string.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final AuthServices authServices = Get.find();
  final FirebaseAuth fbAuth = FirebaseAuth.instance;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  RxBool isLoading = RxBool(false);

  void onSumbit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final credentials = await fbAuth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: confirmPassController.text,
      );
      await fbAuth.currentUser?.updateDisplayName(nameController.text);
      await authServices.createFbUser(credentials, name: nameController.text);
      isLoading.value = false;
      Get.offAllNamed(authServices.verify());
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      onFbSignUpException(e);
    } catch (e) {
      isLoading.value = false;
      logPrint('FbLogin: $e');
    }
  }

  void onFbSignUpException(FirebaseAuthException e) {
    logPrint('FbAuth: $e');
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
        showToast(e.message ?? 'Something went wrong, try again');
    }
  }
}
