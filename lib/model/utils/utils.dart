class Utils {
  static String timeFromNow(DateTime date, now) {
    final diff = now.difference(date);
    if (diff.inDays != 0) {
      switch (diff.inDays) {
        case > 364:
          return '${(diff.inDays / 365).round()} years';
        case > 30:
          return '${(diff.inDays / 30.416).round()} days';
        case > 6:
          return '${(diff.inDays / 7).round()} weeks';
        case 1:
          return '1 day';
        default:
          return '${diff.inDays} days';
      }
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min';
    }

    return 'Just now';
  }
}
