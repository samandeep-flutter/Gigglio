import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gigglio/data/models/user_details.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/config/routes/routes.dart';
import 'package:go_router/go_router.dart';
import '../data/utils/color_resources.dart';

class AuthServices {
  AuthServices._init();
  static AuthServices? _to;
  static AuthServices get to => _to ??= AuthServices._init();

  final _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection(FB.users);
  final _about = FirebaseFirestore.instance.collection(FB.about);
  final box = BoxServices.instance;

  final navigationKey = GlobalKey<NavigatorState>();
  BuildContext? get context => navigationKey.currentContext;

  late MyTheme _theme;
  MyTheme get theme => _theme;

  UserDetails? _user;
  UserDetails? get user => _user;
  set user(UserDetails? value) {
    _user = value;
  }

  late String minVersion;

  Future<AuthServices> init() async {
    _theme = box.getTheme();
    _getVersion();
    return this;
  }

  String get initialRoute {
    if (_auth.currentUser == null) return AppRoutes.signIn;
    return AppRoutes.rootView;
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

  Future<void> saveProfile(String? bio) async {
    final user = _auth.currentUser;
    if (user == null) return;
    var details = UserDetails(
        id: user.uid,
        displayName: user.displayName ?? '',
        email: user.email!,
        image: user.photoURL,
        bio: bio?.isNotEmpty ?? false ? bio : null,
        login: true,
        verified: user.emailVerified);

    final saved = box.getUserDetails();
    final updated = saved?.copyFrom(details: details);
    this.user = updated ?? details;
    await _users.doc(user.uid).update({
      'image': this.user?.image,
      'display_name': this.user?.displayName,
      'bio': this.user?.bio,
    });
    await box.saveUserDetails(updated ?? details);
  }

  Future<void> createFbUser(UserCredential credentials,
      {required String name}) async {
    if (credentials.user == null) return;
    var details = UserDetails(
        id: credentials.user!.uid,
        displayName: name,
        email: credentials.user!.email!,
        image: credentials.user?.photoURL,
        notiSeen: 0,
        login: true,
        verified: credentials.user?.emailVerified);

    try {
      await _users.doc(details.id).set(details.toJson());
      await box.saveUserDetails(details);
      user = details;
    } catch (e) {
      logPrint(e, 'createFbUser');
    }
  }

  Future<void> getUserDetails() async {
    try {
      final doc = await _users.doc(_auth.currentUser!.uid).get();
      user = UserDetails.fromJson(doc.data()!);
    } catch (e) {
      logPrint(e, 'getDetails');
      // ignore: use_build_context_synchronously
      logout();
    }
  }

  Future<void> fetchFbUser(UserCredential credentials) async {
    final user = credentials.user;
    if (user == null) return;
    try {
      final json = await _users.doc(user.uid).get();
      this.user = UserDetails.fromJson(json.data()!)
          .copyWith(login: true, verified: user.emailVerified);
    } catch (_) {
      var details = UserDetails(
          id: user.uid,
          displayName: user.displayName ?? '',
          email: user.email!,
          image: user.photoURL,
          login: true,
          notiSeen: 0,
          verified: user.emailVerified);
      await _users.doc(details.id).set(details.toJson());
      this.user = details;
    }
    await box.saveUserDetails(this.user!);
  }

  void logout() async {
    try {
      if (user != null) {
        final doc = _users.doc(user!.id);
        doc.update({'login': false});
      }
      await _auth.signOut();
      box.removeUserDetails();
    } catch (e) {
      logPrint(e, 'LOGOUT');
    }
    context?.goNamed(AppRoutes.signIn);
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
  //     logPrint(e.toString());
  //   }
  // }
}
