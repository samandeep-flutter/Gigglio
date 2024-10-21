import 'package:flutter/material.dart';
import 'package:gigglio/model/utils/color_resources.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/services/theme_services.dart';

class RadioColorTile extends StatefulWidget {
  final MyTheme value;
  const RadioColorTile({super.key, required this.value});

  @override
  State<RadioColorTile> createState() => _RadioColorTileState();
}

class _RadioColorTileState extends State<RadioColorTile> {
  MyTheme? groupValue;
  double radius = 15;

  @override
  void didChangeDependencies() {
    groupValue = _getTheme(ThemeServices.of(context).text);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = ThemeServices.of(context);
    return RadioListTile(
      value: widget.value,
      groupValue: groupValue,
      title: Text(
        widget.value.title,
        style: TextStyle(
            color: scheme.textColor,
            fontSize: Dimens.fontLarge,
            fontWeight: FontWeight.w600),
      ),
      activeColor: scheme.primary,
      secondary: CircleAvatar(
          radius: radius,
          backgroundColor: ColorRes.secondaryLight,
          child: CircleAvatar(
            radius: radius - 4,
            backgroundColor: widget.value.primary,
          )),
      onChanged: (value) {
        setState(() {
          groupValue = value;
        });
        ThemeServices.maybeOf(context)?.changeTheme(value);
        Future.delayed(const Duration(milliseconds: 500))
            // ignore: use_build_context_synchronously
            .then((value) => Navigator.pop(context));
      },
    );
  }

  MyTheme _getTheme(String? value) {
    return MyTheme.values.firstWhere(
      (element) => element.title == value,
      orElse: () => MyTheme.values.first,
    );
  }
}
