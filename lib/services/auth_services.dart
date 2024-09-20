import 'package:get/get.dart';
import 'package:gigglio/model/models/user_details.dart';
import 'package:gigglio/services/box_services.dart';
import 'package:gigglio/view_models/routes/routes.dart';
import '../model/utils/color_resources.dart';

class AuthServices extends GetxService {
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
    if (user.value == null) {
      return Routes.signIn;
    }
    return Routes.rootView;
  }

  void logout() {
    Get.offAllNamed(Routes.signIn);
  }
}
