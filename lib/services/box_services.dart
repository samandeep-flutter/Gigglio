import 'package:get_storage/get_storage.dart';
import '../model/models/user_details.dart';
import '../model/utils/color_resources.dart';
import '../model/utils/string.dart';

class BoxServices {
  static BoxServices? _instance;
  static BoxServices get instance => _instance ??= BoxServices._init();

  BoxServices._init();

  final box = GetStorage(StringRes.boxName);

  MyTheme getTheme() {
    String? title = box.read(StringRes.keyTheme);
    return MyTheme.values.firstWhere(
      (element) => element.title == title,
      orElse: () => MyTheme.values.first,
    );
  }

  UserDetails? getUserDetails() {
    try {
      var details = box.read(StringRes.keyUser);
      return UserDetails.fromJson(details);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserDetails(UserDetails details) async {
    var value = details.toJson();
    await box.write(StringRes.keyUser, value);
  }

  Future<void> saveTheme(MyTheme theme) async {
    await box.write(StringRes.keyTheme, theme.title);
  }

  Future<void> clear() async => await box.erase();
  Future<void> removeUserDetails() async => box.remove(StringRes.keyUser);
}
