import 'package:gigglio/model/models/user_details.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/utils/color_resources.dart';
import '../model/utils/string.dart';

class BoxServices {
  static BoxServices? _instance;
  static BoxServices get instance => _instance ??= BoxServices._init();

  BoxServices._init();

  Box box = Hive.box(StringRes.boxName);

  MyTheme getTheme() {
    String? title = box.get(StringRes.keyTheme);
    return MyTheme.values.firstWhere(
      (element) => element.title == title,
      orElse: () => MyTheme.values.first,
    );
  }

  UserDetails? getUserDetails() {
    try {
      return UserDetails.fromJson(box.get(StringRes.keyUser));
    } catch (_) {
      return null;
    }
  }

  Future<UserDetails?> saveUserDetails(UserDetails details) async {
    box.put(StringRes.keyUser, details.toJson());
    return getUserDetails();
  }

  void saveTheme(MyTheme theme) async {
    await box.put(StringRes.keyTheme, theme.title);
  }
}
