import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/auth_services.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/services/getit_instance.dart';

class ViewRequestEvents extends Equatable {
  const ViewRequestEvents();

  @override
  List<Object?> get props => [];
}

class ViewRequestInitial extends ViewRequestEvents {}

class RequestAccepted extends ViewRequestEvents {
  final String id;
  const RequestAccepted(this.id);

  @override
  List<Object?> get props => [id, ...super.props];
}

class ViewRequestState extends Equatable {
  final bool isLoading;
  final List<UserDetails> requests;
  final List<String> reqAccepted;

  const ViewRequestState({
    required this.isLoading,
    required this.requests,
    required this.reqAccepted,
  });

  const ViewRequestState.init()
      : isLoading = false,
        reqAccepted = const [],
        requests = const [];

  ViewRequestState copyWith({
    bool? isLoading,
    List<UserDetails>? requests,
    List<String>? reqAccepted,
  }) {
    return ViewRequestState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      reqAccepted: reqAccepted ?? this.reqAccepted,
    );
  }

  @override
  List<Object?> get props => [isLoading, requests, reqAccepted];
}

class ViewRequestsBloc extends Bloc<ViewRequestEvents, ViewRequestState> {
  ViewRequestsBloc() : super(const ViewRequestState.init()) {
    on<ViewRequestInitial>(_onInit);
    on<RequestAccepted>(_onAccepted);
  }

  final users = FirebaseFirestore.instance.collection(FBKeys.users);
  final uid = BoxServices.instance.uid;

  final AuthServices auth = getIt();

  void _onInit(ViewRequestInitial event, Emitter<ViewRequestState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final query = await this.users.get();
      var users =
          query.docs.map((e) => UserDetails.fromJson(e.data())).toList();
      final cUser = users.firstWhere((e) => e.id == uid!);
      users.removeWhere((e) => !(cUser.requests.contains(e.id)));
      emit(state.copyWith(requests: users));
    } catch (e) {
      logPrint(e, 'Requests');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  _onAccepted(RequestAccepted event, Emitter<ViewRequestState> emit) async {
    try {
      users.doc(event.id).update({
        'friends': FieldValue.arrayUnion([uid!]),
      });
      users.doc(uid!).update({
        'friends': FieldValue.arrayUnion([event.id]),
        'requests': FieldValue.arrayRemove([event.id]),
      });
      final accepted = List<String>.from(state.reqAccepted);
      accepted.add(event.id);
      emit(state.copyWith(reqAccepted: accepted));
      final noti = NotiDbModel(
        from: uid!,
        to: event.id,
        dateTime: DateTime.now(),
        category: NotiCategory.reqAccepted,
      );
      auth.sendNotification(noti);
    } catch (e) {
      logPrint(e, 'req accepted');
    }
  }
}
