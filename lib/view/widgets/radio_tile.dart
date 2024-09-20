import 'package:flutter/material.dart';
import 'package:gigglio/model/utils/color_resources.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/services/theme_services.dart';

class MyRadioTile extends StatefulWidget {
  final MyTheme value;
  const MyRadioTile({super.key, required this.value});

  @override
  State<MyRadioTile> createState() => _MyRadioTileState();
}

class _MyRadioTileState extends State<MyRadioTile> {
  MyTheme? groupValue;

  @override
  void didChangeDependencies() {
    groupValue = _getTheme(value: ThemeServices.of(context).text);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      value: widget.value,
      groupValue: groupValue,
      secondary: CircleAvatar(
          radius: 15,
          backgroundColor: ColorRes.secondaryLight,
          child: CircleAvatar(
            radius: 10,
            backgroundColor: widget.value.primary,
          )),
      title: Text(
        widget.value.title,
        style: const TextStyle(
            fontSize: Dimens.fontLarge, fontWeight: FontWeight.w600),
      ),
      onChanged: (value) {
        groupValue = value;
        ThemeServices.maybeOf(context)?.changeTheme(value);
        Future.delayed(const Duration(milliseconds: 500))
            .then((value) => Navigator.pop(context));
      },
    );
  }

  MyTheme _getTheme({String? value}) {
    return MyTheme.values.firstWhere(
      (element) => element.title == value,
      orElse: () => MyTheme.values.first,
    );
  }
}
