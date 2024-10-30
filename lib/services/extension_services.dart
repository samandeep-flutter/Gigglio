extension MyDateTime on DateTime {
  String get toJson => _dateTime(this);

  String _dateTime(DateTime now) {
    String date = '${now.year}${_format(now.month)}${_format(now.day)}';
    String time = '${_format(now.hour)}${_format(now.minute)}'
        '${_format(now.second)}${_formatMili(now.millisecond)}';
    return date + time;
  }

  String _formatMili(int number) {
    String int = number.toString();
    switch (int.length) {
      case 2:
        return '0$int';
      case 1:
        return '00$int';
      default:
        return int;
    }
  }

  String _format(int number) {
    String int = number.toString();
    String result = int.length > 2 ? '0$int' : int;
    return result;
  }
}

extension MyString on String {
  DateTime get toDateTime => _formJson(this);

  DateTime _formJson(String datetime) {
    int year = int.parse(datetime.substring(0, 4));
    int month = int.parse(datetime.substring(4, 6));
    int day = int.parse(datetime.substring(6, 8));
    int hour = int.parse(datetime.substring(8, 10));
    int min = int.parse(datetime.substring(10, 12));
    int milli = int.parse(datetime.substring(12, 16));
    return DateTime(year, month, day, hour, min, milli);
  }
}
