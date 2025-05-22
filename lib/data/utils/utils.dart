import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/data/utils/string.dart';
import 'package:gigglio/services/extension_services.dart';
import 'package:rxdart/rxdart.dart';

class Utils {
  static EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  static String formatDate(DateTime date) {
    switch (DateTime.now().day - date.day) {
      case 0:
        return StringRes.today;
      case 1:
        return StringRes.yesterday;
      default:
        return date.formatDate;
    }
  }

  static String timeFromNow(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
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

  static SliverGridDelegate gridDelegate(int crossAxisCount,
      {double? spacing}) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing ?? 0,
      crossAxisSpacing: spacing ?? 0,
    );
  }
}
