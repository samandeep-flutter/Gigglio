import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import '../model/utils/color_resources.dart';

class AuthServices extends GetxService {
  final _auth = FirebaseAuth.instance;
  late MyTheme _theme;
  MyTheme get theme => _theme;
  Rxn<UserDetails> user = Rxn();

  @override
  onInit() {
    _theme = BoxServices.instance.getTheme();
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

  Future<void> saveCred(UserCredential credentials) async {
    if (credentials.user == null) return;
    var details = UserDetails(
        id: credentials.user?.uid,
        username: credentials.user?.displayName,
        email: credentials.user?.email,
        image: credentials.user?.photoURL,
        verified: credentials.user?.emailVerified);
    user.value = await BoxServices.instance.saveUserDetails(details);
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.signIn);
  }
}
