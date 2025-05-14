import 'package:get_storage/get_storage.dart';
import 'package:gigglio/data/utils/app_constants.dart';
import '../data/data_models/user_details.dart';
import '../data/utils/color_resources.dart';

class BoxServices {
  static BoxServices? _instance;
  static BoxServices get instance => _instance ??= BoxServices._init();

  BoxServices._init();

  final box = GetStorage(BoxKeys.boxName);

  MyTheme getTheme() {
    String? title = box.read(BoxKeys.theme);
    return MyTheme.values.firstWhere(
      (element) => element.title == title,
      orElse: () => MyTheme.values.first,
    );
  }

  UserDetails? getUserDetails() {
    try {
      var details = box.read(BoxKeys.user);
      return UserDetails.fromJson(details);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserDetails(UserDetails? details) async {
    if (details == null) return;
    final value = details.toJson();
    await box.write(BoxKeys.user, value);
  }

  Future<void> saveTheme(MyTheme theme) async {
    await box.write(BoxKeys.theme, theme.title);
  }

  Future<void> clear() async => await box.erase();
  Future<void> removeUserDetails() async => box.remove(BoxKeys.theme);
}
