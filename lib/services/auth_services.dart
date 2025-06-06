import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/repository/auth_repo.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:gigglio/services/getit_instance.dart';
import 'package:go_router/go_router.dart';

class AuthServices {
  AuthServices._init();
  static AuthServices? _to;
  static AuthServices get to => _to ??= AuthServices._init();

  final _auth = FirebaseAuth.instance;
  final box = BoxServices.instance;
  final AuthRepo repo = getIt();

  final _users = FirebaseFirestore.instance.collection(FBKeys.users);
  final _about = FirebaseFirestore.instance.collection(FBKeys.about);
  final _noti = FirebaseFirestore.instance.collection(FBKeys.noti);

  final navigationKey = GlobalKey<NavigatorState>();
  BuildContext? get navContext => navigationKey.currentContext;

  late String minVersion;

  Future<AuthServices> init() async {
    Future(_getVersion);
    return this;
  }

  String get initialRoute {
    try {
      _auth.currentUser as User;
      return AppRoutes.rootView;
    } catch (_) {
      return AppRoutes.signIn;
    }
  }

  Future<void> _getVersion() async {
    if (_auth.currentUser == null) return;
    try {
      final doc = await _about.doc('info').get();
      minVersion = doc.data()!['min_version'];
    } catch (e) {
      logPrint(e, 'FB');
    }
  }

  Future<void> sendNotification(NotiDbModel noti) async {
    _noti.add(noti.toJson());
    final json = await _users.doc(noti.to).get();
    final user = UserDetails.fromJson(json.data()!);
    if (!(user.login ?? false)) return;
    repo.sendNotification(user.deviceToken, sender: user, noti: noti.category);
  }

  void logout() async {
    try {
      if (_auth.currentUser != null) {
        final doc = _users.doc(_auth.currentUser!.uid);
        doc.update({'login': false});
      }
      await _auth.signOut();
      box.removeUserDetails();
    } catch (e) {
      logPrint(e, 'LOGOUT');
    }
    navContext?.goNamed(AppRoutes.signIn);
  }

  /// Currently disalbed through firebase
  // void deleteUser() async {
  //   try {
  //     await _auth.currentUser?.delete();
  //     Get.offAllNamed(AppRoutes.signIn);
  //   } on FirebaseAuthException catch (e) {
  //     logPrint(e, 'FbDelete');
  //     if (e.code == 'requires-recent-login') {
  //       showToast('You need to re-login, in order to delete this account');
  //       Get.offAllNamed(AppRoutes.signIn);
  //     }
  //   } catch (e) {
  //     logPrint(e, 'FbDelete');
  //   }
  // }
}
