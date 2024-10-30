import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/theme_services.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/utils/color_resources.dart';
import '../../model/utils/string.dart';
import '../../view/widgets/top_widgets.dart';
import '../routes/routes.dart';

class ProfileController extends GetxController {
  AuthServices authServices = Get.find();
  final _user = FirebaseAuth.instance.currentUser;
  final _storage = FirebaseStorage.instance.ref();

  final nameController = TextEditingController();
  final nameKey = GlobalKey<FormFieldState>();

  final changePassKey = GlobalKey<FormState>();
  final oldPassContr = TextEditingController();
  final newPassContr = TextEditingController();
  final confirmPassContr = TextEditingController();

  RxBool isProfileLoading = RxBool(false);
  RxBool isChangePassLoading = RxBool(false);
  RxBool isImageLoading = RxBool(false);
  RxnString imageUrl = RxnString();

  void toChangePassword() => Get.toNamed(Routes.changePass);

  void changePassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(changePassKey.currentState?.validate() ?? false)) return;
    isChangePassLoading.value = true;
    try {
      await _user!.updatePassword(confirmPassContr.text);
    } on FirebaseAuthException catch (e) {
      isChangePassLoading.value = false;
      logPrint('ChangePass: $e');
      if (e.code == 'requires-recent-login') {
        showDialog(
            context: Get.context!,
            builder: (context) {
              return MyAlertDialog(
                title: 'Re-Authenticate',
                content: const Text(StringRes.reauthDesc),
                actions: [
                  TextButton(
                    onPressed: Get.back,
                    child: const Text(StringRes.cancel),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: authServices.logout,
                    child: const Text('Re-Authenticate'),
                  ),
                ],
              );
            });
      }
    } catch (e) {
      isChangePassLoading.value = false;
      logPrint('ChangePass: $e');
    }
  }

  void imagePicker(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
              actions: const [],
              actionPadding: EdgeInsets.zero,
              title: 'Pick from',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () => _pickImage(ImageSource.gallery),
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Gallary'),
                  ),
                  ListTile(
                    onTap: () => _pickImage(ImageSource.camera),
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Camera'),
                  ),
                ],
              ));
        });
  }

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    Get.back();
    isImageLoading.value = true;
    try {
      XFile? file = await picker.pickImage(source: source, imageQuality: 15);
      if (file == null) throw StringRes.cancelled;

      String? url = await _savetoFB(file);
      isImageLoading.value = false;
      imageUrl.value = url;
    } catch (e) {
      isImageLoading.value = false;
      logPrint('ImagePicker: $e');
    }
  }

  Future<String?> _savetoFB(XFile xfile) async {
    try {
      File file = File(xfile.path);
      String ext = xfile.path.split('.').last;
      final ref = _storage.child(
        AppConstants.profileImage(ext),
      );

      await ref.putFile(file);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      logPrint('FBstorage: $e');
      return null;
    }
  }

  void toEditProfile() {
    nameController.text = authServices.user.value?.displayName ?? '';
    imageUrl.value = authServices.user.value?.image;
    Get.toNamed(Routes.editProfile);
  }

  void fromEditProfile(bool canPop, result) => nameKey.currentState?.reset();

  void fromChangePass(bool canPop, result) =>
      changePassKey.currentState?.reset();

  void editProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(nameKey.currentState?.validate() ?? false)) return;
    if (isImageLoading.value) return;
    isProfileLoading.value = true;
    final user = authServices.user.value;
    try {
      final modifiedUrl = imageUrl.value != user?.image;
      if (modifiedUrl) {
        await _user!.updatePhotoURL(imageUrl.value);
      }
      final modifiedName = nameController.text != user?.displayName;
      if (modifiedName) {
        await _user!.updateDisplayName(nameController.text);
      }
      await authServices.saveProfile();
      isProfileLoading.value = false;
      Get.back();
    } catch (e) {
      isProfileLoading.value = false;
      logPrint('EditProfile: $e');
      authServices.logout();
    }
  }

  void toPrivacyPolicy() => Get.toNamed(Routes.privacyPolicy);

  void toSettings() => Get.toNamed(Routes.settings);

  void logout(BuildContext context) {
    final scheme = ThemeServices.of(context);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return MyAlertDialog(
            title: '${StringRes.logout}?',
            content: const Text(StringRes.logoutDesc),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: scheme.textColorLight),
                onPressed: Get.back,
                child: Text(StringRes.cancel.toUpperCase()),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: ColorRes.onErrorContainer),
                  onPressed: authServices.logout,
                  child: Text(StringRes.logout.toUpperCase())),
            ],
          );
        });
  }
}
