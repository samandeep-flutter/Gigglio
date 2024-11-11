extension MyDateTime on DateTime {
  String toJson() => _dateTime(this);
  String get formatTime => _formatedTime(this);
  String get formatDate => _formatedDate(this);

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

  String _formatedTime(DateTime time) {
    String hour = _format(time.hour);
    String min = _format(time.minute);

    return '$hour:$min';
  }

  String _formatedDate(DateTime time) {
    String month = _format(time.month);
    String day = _format(time.day);

    return '$month:$day';
  }

  String _format(int number) {
    String int = number.toString();
    String result = int.length > 1 ? int : '0$int';
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
    int sec = int.parse(datetime.substring(12, 14));
    int milli = int.parse(datetime.substring(14, 17));
    return DateTime(year, month, day, hour, min, sec, milli);
  }
}
