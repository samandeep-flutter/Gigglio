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

  @override
  onInit() {
    _theme = boxServices.getTheme();
    user.listen((value) {
      if (value == null) return;
      final doc = _fbFire.collection(FB.users).doc(value.id);
      doc.set(value.toJson());
      logPrint('[UserDetails] saved to Firestore');
    });
    super.onInit();
  }

  Future<AuthServices> init() async {
    return this;
  }

  String initRoutes() {
    if (_auth.currentUser == null) {
      return Routes.signIn;
    }
    return Routes.rootView;
  }

  Future<void> saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    var details = UserDetails(
        id: user.uid,
        displayName: user.displayName ?? '',
        email: user.email!,
        image: user.photoURL,
        verified: user.emailVerified);
    this.user.value = details;
    await boxServices.saveUserDetails(details);
  }

  Future<void> saveCred(UserCredential credentials) async {
    if (credentials.user == null) return;
    var details = UserDetails(
        id: credentials.user!.uid,
        displayName: credentials.user!.displayName ?? '',
        email: credentials.user!.email!,
        image: credentials.user?.photoURL,
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

  void logout() async {
    try {
      await _auth.signOut();
      await boxServices.removeUserDetails();
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
