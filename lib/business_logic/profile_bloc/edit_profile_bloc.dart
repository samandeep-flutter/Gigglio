import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/utils/app_constants.dart';
import '../../data/utils/string.dart';
import '../../services/auth_services.dart';

class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileEvent {}

class EditProfileImage extends EditProfileEvent {
  final ImageSource source;
  const EditProfileImage(this.source);

  @override
  List<Object?> get props => [source, ...super.props];
}

class EditProfileSubmit extends EditProfileEvent {}

class EditProfileState extends Equatable {
  final String? imageUrl;
  final bool profileLoading;
  final bool imageLoading;
  final bool success;

  const EditProfileState({
    required this.imageUrl,
    required this.profileLoading,
    required this.imageLoading,
    required this.success,
  });

  const EditProfileState.init()
      : imageUrl = null,
        success = false,
        profileLoading = false,
        imageLoading = false;

  EditProfileState copyWith({
    String? imageUrl,
    bool? profileLoading,
    bool? imageLoading,
    bool? success,
  }) {
    return EditProfileState(
      imageUrl: imageUrl ?? this.imageUrl,
      profileLoading: profileLoading ?? this.profileLoading,
      imageLoading: imageLoading ?? this.imageLoading,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [imageUrl, profileLoading, imageLoading, success];
}

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState.init()) {
    on<EditProfileInitial>(_onInit);
    on<EditProfileImage>(_onPickImage);
    on<EditProfileSubmit>(_onSubmit);
  }

  final _user = FirebaseAuth.instance.currentUser;
  final storage = FirebaseStorage.instance.ref();
  final AuthServices auth = getIt();
  final picker = ImagePicker();

  final nameController = TextEditingController();
  final bioContr = TextEditingController();
  final editFormKey = GlobalKey<FormState>();

  _onInit(EditProfileInitial event, Emitter<EditProfileState> emit) {
    nameController.text = auth.user?.displayName ?? '';
    bioContr.text = auth.user?.bio ?? '';
    emit(state.copyWith(imageUrl: auth.user?.image));
  }

  void _onPickImage(
      EditProfileImage event, Emitter<EditProfileState> emit) async {
    emit(state.copyWith(imageLoading: true));
    try {
      final file =
          await picker.pickImage(source: event.source, imageQuality: 30);
      if (file == null) throw StringRes.cancelled;
      String? url = await _savetoFB(file);
      emit(state.copyWith(imageUrl: url));
    } catch (e) {
      logPrint(e, 'ImagePicker');
    } finally {
      emit(state.copyWith(imageLoading: false));
    }
  }

  Future<String?> _savetoFB(XFile xfile) async {
    File file = File(xfile.path);
    String ext = xfile.path.split('.').last;
    if (state.imageUrl != null) {
      final storage = FirebaseStorage.instance;
      try {
        final ref = storage.refFromURL(state.imageUrl!);
        await ref.delete();
      } catch (_) {}
    }
    try {
      final path = '${auth.user!.id}.$ext';
      final ref = storage.child(AppConstants.profileImage(path));
      await ref.putFile(file);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      logPrint(e, 'FBstorage');
      return null;
    }
  }

  void _onSubmit(
      EditProfileSubmit event, Emitter<EditProfileState> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(editFormKey.currentState?.validate() ?? false)) return;
    emit(state.copyWith(profileLoading: true));
    try {
      if (state.imageUrl != auth.user?.image) {
        await _user!.updatePhotoURL(state.imageUrl);
      }
      if (nameController.text != auth.user?.displayName) {
        await _user!.updateDisplayName(nameController.text);
      }
      await auth.saveProfile(bioContr.text.trim());
      emit(state.copyWith(success: true));
    } catch (e) {
      logPrint(e, 'EditProfile');
      // auth.logout();
    } finally {
      emit(state.copyWith(profileLoading: false));
    }
  }
}
