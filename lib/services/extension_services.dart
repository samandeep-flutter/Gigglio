import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/services/theme_services.dart';

extension MyContext on BuildContext {
  ThemeServiceState get scheme => ThemeServices.of(this);
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;

  double get bottomInsets => MediaQuery.viewInsetsOf(this).bottom;
  Orientation get orientation => MediaQuery.orientationOf(this);
  double get statusBarHeight => MediaQuery.paddingOf(this).top;
  double get bottomBarHeight => MediaQuery.paddingOf(this).bottom;
  TextStyle? get subtitleTextStyle =>
      Theme.of(this).textTheme.bodyMedium?.copyWith(color: scheme.disabled);

  void popUntil(String path) {
    Navigator.popUntil(this, ModalRoute.withName(path));
  }

  void close(int count) {
    int popped = 0;
    Navigator.of(this).popUntil((route) => popped++ >= count);
  }
}

extension MyList<T> on List<T> {
  String get asString => _removeBraces(this);

  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  String _removeBraces(List<T> list) {
    final string = list.toString().replaceAll(RegExp(r'[\[\]]'), '');
    return jsonEncode(string);
  }
}

extension CategoryExtensions on NotiCategory {
  bool get isRequest =>
      this == NotiCategory.request || this == NotiCategory.reqAccepted;
}

// extension MusicDuration on Duration {
//   String format() => _format(this);

//   String _format(Duration time) {
//     if (time.inMinutes >= 60) {
//       final min = time.inMinutes - (time.inHours * 60);
//       return '${time.inHours}:${_formatInt(min)}';
//     }
//     if (time.inSeconds >= 60) {
//       final sec = time.inSeconds - (time.inMinutes * 60);
//       return '${time.inMinutes}:${_formatInt(sec)}';
//     }
//     return '0:${_formatInt(time.inSeconds)}';
//   }

//   String _formatInt(int num) {
//     if (num < 10) return '0$num';
//     return num.toString();
//   }
// }

extension MyDateTime on DateTime {
  String get formatTime => _formatedTime(this);
  String get formatDate => _formatedDate(this);

  // String _dateTime(DateTime now) {
  //   String date = '${now.year}${_format(now.month)}${_format(now.day)}';
  //   String time = '${_format(now.hour)}${_format(now.minute)}'
  //       '${_format(now.second)}${_formatMili(now.millisecond)}';
  //   return date + time;
  // }

  // String _formatMili(int number) {
  //   String int = number.toString();
  //   switch (int.length) {
  //     case 2:
  //       return '0$int';
  //     case 1:
  //       return '00$int';
  //     default:
  //       return int;
  //   }
  // }

  String _formatedTime(DateTime time) {
    String hour = _format(time.hour);
    String min = _format(time.minute);

    return '$hour:$min';
  }

  String _formatedDate(DateTime time) {
    String day = _format(time.day);

    return '${_formatMonth(time.month)} $day, ${time.year}';
  }

  String _format(int number) {
    String int = number.toString();
    String result = int.length > 1 ? int : '0$int';
    return result;
  }

  String _formatMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';

      default:
        return '$month';
    }
  }
}

extension MyString on String {
  bool get isEmail => _emailRegExp(this);
  bool get isStringPass => _passRegExp(this);
  String get capitalize => _capitilize(this);
  // String get unescape => _unescape(this);
  String get removeCoprights => _removeCopyright(this);
  int queryMatch(String query) => _calculateMatch(this, query);

  // DateTime _formJson(String datetime) {
  //   int year = int.parse(datetime.substring(0, 4));
  //   int month = int.parse(datetime.substring(4, 6));
  //   int day = int.parse(datetime.substring(6, 8));
  //   int hour = int.parse(datetime.substring(8, 10));
  //   int min = int.parse(datetime.substring(10, 12));
  //   int sec = int.parse(datetime.substring(12, 14));
  //   int milli = int.parse(datetime.substring(14, 17));
  //   return DateTime(year, month, day, hour, min, sec, milli);
  // }

  _emailRegExp(String text) {
    final emailExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailExp.hasMatch(text);
  }

  _passRegExp(String text) {
    final passExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
    return passExp.hasMatch(text);
  }

  String _capitilize(String text) {
    final RegExp regExp = RegExp(r'[a-zA-Z]');
    return text.replaceFirstMapped(regExp, (match) {
      return match.group(0)!.toUpperCase();
    });
  }

  // String _unescape(String text) => HtmlUnescape().convert(text);

  String _removeCopyright(String text) {
    return text.replaceAll(RegExp(r'\b[CcPp]|\([CcPp]\)'), '');
  }

  int _calculateMatch(String item, String searchText) {
    item = item.toLowerCase();
    searchText = searchText.toLowerCase();
    if (item == searchText) {
      return 3;
    } else if (item.startsWith(searchText)) {
      return 2;
    } else if (item.contains(searchText)) {
      return 1;
    }
    return 0;
  }
}

extension MyInt on int {
  String get format => _format(this);

  String _format(int count) {
    if (count > 999999) {
      String newCount = (count / 1000000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}M';
    }
    if (count > 999) {
      String newCount = (count / 1000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}K';
    }
    return count.toString();
  }
}
