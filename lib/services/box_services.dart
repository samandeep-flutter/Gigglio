import 'package:get_storage/get_storage.dart';
import 'package:gigglio/data/utils/app_constants.dart';
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

  Future<void> saveTheme(MyTheme theme) async {
    await box.write(BoxKeys.theme, theme.title);
  }

  Future<void> write(String key, dynamic value) async {
    await box.write(key, value);
  }

  T? read<T>(String key) => box.read<T>(key);

  Future<void> clear() async => await box.erase();

  Future<void> removeUserDetails() async => box.remove(BoxKeys.theme);
}
