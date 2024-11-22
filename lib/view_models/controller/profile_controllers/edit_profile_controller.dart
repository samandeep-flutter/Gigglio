import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/utils/app_constants.dart';
import '../../../model/utils/string.dart';
import '../../../services/auth_services.dart';
import '../../../view/widgets/top_widgets.dart';

class EditProfileController extends GetxController {
  final AuthServices authServices = Get.find();
  final _user = FirebaseAuth.instance.currentUser;
  final storage = FirebaseStorage.instance.ref();

  final nameController = TextEditingController();
  final bioContr = TextEditingController();
  final editFormKey = GlobalKey<FormState>();

  RxBool isProfileLoading = RxBool(false);
  RxBool isImageLoading = RxBool(false);
  RxnString imageUrl = RxnString();

  @override
  void onInit() {
    final user = authServices.user.value;
    nameController.text = user?.displayName ?? '';

    bioContr.text = user?.bio ?? '';
    imageUrl.value = authServices.user.value?.image;
    super.onInit();
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
    final user = authServices.user.value;

    File file = File(xfile.path);
    String ext = xfile.path.split('.').last;
    if (imageUrl.value != null) {
      final storage = FirebaseStorage.instance;
      try {
        final ref = storage.refFromURL(imageUrl.value!);
        await ref.delete();
      } catch (_) {}
    }
    try {
      final path = AppConstants.profileImage('${user!.id}.$ext');
      final ref = storage.child(path);

      await ref.putFile(file);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      logPrint('FBstorage: $e');
      return null;
    }
  }

  void editProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(editFormKey.currentState?.validate() ?? false)) return;
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
      await authServices.saveProfile(bioContr.text.trim());
      isProfileLoading.value = false;
      Get.back();
    } catch (e) {
      isProfileLoading.value = false;
      logPrint('EditProfile: $e');
      authServices.logout();
    }
  }
}
