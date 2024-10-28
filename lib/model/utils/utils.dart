class Utils {
  static String dateTime(DateTime now) {
    String date = '${now.year}${_format(now.month)}${_format(now.day)}';
    String time = '${_format(now.hour)}${_format(now.minute)}'
        '${_format(now.second)}${_formatMili(now.millisecond)}';
    return date + time;
  }

  static String _formatMili(int number) {
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

  static String _format(int number) {
    String int = number.toString();
    String result = int.length > 2 ? '0$int' : int;
    return result;
  }
}
