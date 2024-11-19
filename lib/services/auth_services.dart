import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/model/utils/app_constants.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import '../model/utils/color_resources.dart';

class AuthServices extends GetxService {
  static AuthServices get to => Get.find();
  final _auth = FirebaseAuth.instance;
  final _fbFire = FirebaseFirestore.instance;
  final boxServices = BoxServices.instance;
  late MyTheme _theme;
  MyTheme get theme => _theme;
  Rxn<UserDetails> user = Rxn();
  late String minVersion;

  @override
  onInit() {
    _theme = boxServices.getTheme();
    user.listen((value) {
      if (value == null) return;
      final doc = _fbFire.collection(FB.users).doc(value.id);
      doc.set(value.toJson());
      logPrint('[UserDetails] saved to Firestore');
      _getVersion();
    });

    super.onInit();
  }

  Future<AuthServices> init() async {
    return this;
  }

  String verify() {
    if (_auth.currentUser == null) return Routes.signIn;
    return Routes.rootView;
  }

  Future<void> _getVersion() async {
    try {
      final doc = await _fbFire.collection(FB.about).doc('info').get();
      minVersion = doc.data()!['min_version'];
    } catch (e) {
      logPrint('FB: $e');
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

    final saved = boxServices.getUserDetails();
    final updated = saved?.copyFrom(details: details);
    this.user.value = updated ?? details;
    await boxServices.saveUserDetails(updated ?? details);
  }

  Future<void> createFbUser(
    UserCredential credentials, {
    required String name,
  }) async {
    if (credentials.user == null) return;
    var details = UserDetails(
        id: credentials.user!.uid,
        displayName: name,
        email: credentials.user!.email!,
        image: credentials.user?.photoURL,
        notiSeen: 0,
        login: true,
        verified: credentials.user?.emailVerified);

    user.value = details;
    await boxServices.saveUserDetails(details);
  }

  Future<void> getUserDetails() async {
    try {
      UserDetails details = boxServices.getUserDetails()!;
      user.value = details;
    } catch (e) {
      logPrint('getDetails: $e');
      logout();
    }
  }

  Future<void> fetchFbUser(UserCredential credentials) async {
    final user = credentials.user;
    if (user == null) return;
    try {
      final json = await _fbFire.collection(FB.users).doc(user.uid).get();
      this.user.value = UserDetails.fromJson(json.data()!)
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
      this.user.value = details;
    }
    await boxServices.saveUserDetails(this.user.value!);
  }

  void logout() async {
    try {
      if (user.value != null) {
        final doc = _fbFire.collection(FB.users).doc(user.value!.id);
        doc.update({'login': false});
      }
      await _auth.signOut();
      boxServices.removeUserDetails();
    } catch (e) {
      logPrint('LOGOUT: $e');
    }
    Get.offAllNamed(Routes.signIn);
  }

  /// Currently disalbed through firebase
  // void deleteUser() async {
  //   try {
  //     await _auth.currentUser?.delete();
  //     Get.offAllNamed(Routes.signIn);
  //   } on FirebaseAuthException catch (e) {
  //     logPrint('FbDelete: $e');
  //     if (e.code == 'requires-recent-login') {
  //       showToast('You need to re-login, in order to delete this account');
  //       Get.offAllNamed(Routes.signIn);
  //     }
  //   } catch (e) {
  //     logPrint(e.toString());
  //   }
  // }
}
