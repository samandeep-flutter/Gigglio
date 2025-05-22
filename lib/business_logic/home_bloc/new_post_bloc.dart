import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/utils/app_constants.dart';

class NewPostEvent extends Equatable {
  const NewPostEvent();

  @override
  List<Object?> get props => [];
}

class NewPostInitial extends NewPostEvent {}

class NewPostPickImages extends NewPostEvent {}

class NewPostRemovePicked extends NewPostEvent {
  final int index;
  const NewPostRemovePicked(this.index);

  @override
  List<Object?> get props => [index, ...super.props];
}

class NewPostSubmit extends NewPostEvent {}

class NewPostState extends Equatable {
  final bool postLoading;
  final bool imageLoading;
  final List<File> postImages;
  final bool success;

  const NewPostState({
    required this.postLoading,
    required this.imageLoading,
    required this.postImages,
    required this.success,
  });

  const NewPostState.init()
      : postLoading = false,
        imageLoading = false,
        success = false,
        postImages = const [];

  NewPostState copyWith({
    bool? postLoading,
    bool? imageLoading,
    List<File>? postImages,
    bool? success,
  }) {
    return NewPostState(
      postLoading: postLoading ?? this.postLoading,
      imageLoading: imageLoading ?? this.imageLoading,
      postImages: postImages ?? this.postImages,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [postLoading, imageLoading, postImages, success];
}

class NewPostBloc extends Bloc<NewPostEvent, NewPostState> {
  NewPostBloc() : super(const NewPostState.init()) {
    on<NewPostInitial>(_onInit);
    on<NewPostPickImages>(_onPickImages);
    on<NewPostSubmit>(_onSubmit);
    on<NewPostRemovePicked>(_onImageRemoved);
  }

  final posts = FirebaseFirestore.instance.collection(FBKeys.post);
  final storage = FirebaseStorage.instance.ref();
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final captionContr = TextEditingController();
  final picker = ImagePicker();

  void _onInit(NewPostInitial event, Emitter<NewPostState> emit) {
    captionContr.clear();
  }

  void _onPickImages(
      NewPostPickImages event, Emitter<NewPostState> emit) async {
    emit(state.copyWith(imageLoading: true));
    try {
      final picked = await picker.pickMultiImage(
          imageQuality: 20, requestFullMetadata: false);
      if (picked.isEmpty) throw Exception('No image selected');
      final _images = List<File>.from(state.postImages);
      _images.addAll(picked.map((e) => File(e.path)));
      emit(state.copyWith(postImages: _images));
    } catch (e) {
      logPrint(e, 'ImagePicker');
    } finally {
      emit(state.copyWith(imageLoading: false));
    }
  }

  Future<List<String>> _uploadImages(List<File> images,
      {required String doc}) async {
    List<String> list = [];
    for (var image in images) {
      final path = image.path.split('/').last;
      final ref = storage.child(AppConstants.postImage('$doc/$path'));
      await ref.putFile(image);
      list.add(await ref.getDownloadURL());
    }
    return list;
  }

  _onImageRemoved(NewPostRemovePicked event, Emitter<NewPostState> emit) {
    final images = List<File>.from(state.postImages);
    images.removeAt(event.index);
    emit(state.copyWith(postImages: images));
  }

  void _onSubmit(NewPostSubmit event, Emitter<NewPostState> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      emit(state.copyWith(postLoading: true));
      final post = PostModel.add(
        author: userId,
        desc: captionContr.text,
        dateTime: DateTime.now(),
      );
      final doc = await posts.add(post.toJson());
      _uploadImages(state.postImages, doc: doc.id).then((images) {
        posts.doc(doc.id).update({'images': images});
      });
      showToast('Posting...');
      emit(state.copyWith(success: true));
    } catch (e) {
      logPrint(e, 'NewPost');
    } finally {
      emit(state.copyWith(postLoading: false));
    }
  }
}
