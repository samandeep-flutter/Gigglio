import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/utils/app_constants.dart';
import '../../data/utils/string.dart';

class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileEvent {
  final UserDetails profile;
  const EditProfileInitial(this.profile);

  @override
  List<Object?> get props => [profile, ...super.props];
}

class EditProfileImage extends EditProfileEvent {
  final ImageSource source;
  const EditProfileImage(this.source);

  @override
  List<Object?> get props => [source, ...super.props];
}

class EditProfileSubmit extends EditProfileEvent {}

class EditProfileState extends Equatable {
  final UserDetails? profile;
  final String? imageUrl;
  final bool profileLoading;
  final bool imageLoading;
  final bool success;

  const EditProfileState({
    required this.profile,
    required this.imageUrl,
    required this.profileLoading,
    required this.imageLoading,
    required this.success,
  });

  const EditProfileState.init()
      : imageUrl = null,
        success = false,
        profile = null,
        profileLoading = false,
        imageLoading = false;

  EditProfileState copyWith({
    UserDetails? profile,
    String? imageUrl,
    bool? profileLoading,
    bool? imageLoading,
    bool? success,
  }) {
    return EditProfileState(
      profile: profile ?? this.profile,
      imageUrl: imageUrl ?? this.imageUrl,
      profileLoading: profileLoading ?? this.profileLoading,
      imageLoading: imageLoading ?? this.imageLoading,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props =>
      [profile, imageUrl, profileLoading, imageLoading, success];
}

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState.init()) {
    on<EditProfileInitial>(_onInit);
    on<EditProfileImage>(_onPickImage);
    on<EditProfileSubmit>(_onSubmit);
  }

  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final _user = FirebaseAuth.instance.currentUser;
  final storage = FirebaseStorage.instance;

  final picker = ImagePicker();

  final nameController = TextEditingController();
  final bioContr = TextEditingController();
  final editFormKey = GlobalKey<FormState>();

  _onInit(EditProfileInitial event, Emitter<EditProfileState> emit) {
    nameController.text = event.profile.displayName;
    bioContr.text = event.profile.bio ?? '';
    emit(state.copyWith(imageUrl: event.profile.image));
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
      try {
        final ref = storage.refFromURL(state.imageUrl!);
        await ref.delete();
      } catch (_) {}
    }
    try {
      final path = AppConstants.profileImage('${_user!.uid}.$ext');
      final ref = storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
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
      if (state.imageUrl != state.profile?.image) {
        await _user!.updatePhotoURL(state.imageUrl);
      }
      if (nameController.text != state.profile?.displayName) {
        await _user!.updateDisplayName(nameController.text);
      }
      await users.doc(_user!.uid).update({
        'image': _user.photoURL,
        'display_name': _user.displayName,
        'bio': bioContr.text.trim()
      });
      emit(state.copyWith(success: true));
    } catch (e) {
      logPrint(e, 'EditProfile');
    } finally {
      emit(state.copyWith(profileLoading: false));
    }
  }
}
