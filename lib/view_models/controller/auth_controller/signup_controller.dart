import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/model/utils/string.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';

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
    if (!(formKey.currentState?.validate() ?? true)) return;
    isLoading.value = true;
    try {
      final credentials = await fbAuth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: confirmPassController.text,
      );
      await fbAuth.currentUser?.updateDisplayName(nameController.text);
      await authServices.saveCred(credentials);
      isLoading.value = false;
      Get.offAllNamed(Routes.rootView);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'invalid-email') {
        showToast('Enter valid email address.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      }
    } catch (e) {
      isLoading.value = false;
      logPrint('FbLogin: $e');
    }
  }
}
