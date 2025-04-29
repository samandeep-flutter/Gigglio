import 'package:flutter/material.dart';
import 'package:gigglio/data/utils/dimens.dart';

class Utils {
  static String timeFromNow(DateTime? date, DateTime now) {
    if (date == null) return '';
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      switch (diff.inDays) {
        case > 364:
          return '${(diff.inDays / 365).round()} years ago';
        case > 30:
          return '${(diff.inDays / 30.416).round()} days ago';
        case > 6:
          return '${(diff.inDays / 7).round()} weeks ago';
        case 1:
          return '1 day ago';
        default:
          return '${diff.inDays} days ago';
      }
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min ago';
    }

    return 'Just now';
  }

  static TextStyle get defTitleStyle {
    return const TextStyle(
      fontSize: Dimens.fontExtraLarge,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
  }

  static EdgeInsets paddingHoriz(double padding) {
    return EdgeInsets.symmetric(horizontal: padding);
  }

  static ShapeBorder roundedRectangle(double border) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(border));
  }
}
