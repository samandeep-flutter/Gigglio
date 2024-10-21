import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/dimens.dart';
import 'package:gigglio/services/theme_services.dart';

import '../../model/utils/string.dart';

class MyTextField extends StatefulWidget {
  final Key? fieldKey;
  final String title;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextCapitalization? capitalization;
  final InputDecoration? decoration;
  final int maxLines;
  final int? maxLength;
  final bool isEmail;
  final bool isPass;
  final bool isNumber;
  final String? Function(String? value)? customValidator;
  final List<TextInputFormatter>? inputFormatters;
  const MyTextField(
      {super.key,
      this.fieldKey,
      required this.title,
      this.controller,
      this.keyboardType,
      this.focusNode,
      this.capitalization,
      this.maxLines = 1,
      this.maxLength,
      this.isEmail = false,
      this.isNumber = false,
      this.isPass = false,
      this.customValidator,
      this.inputFormatters,
      this.obscureText = false})
      : decoration = null;

  const MyTextField._search({
    this.fieldKey,
    required this.title,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.capitalization,
    this.customValidator,
    this.inputFormatters,
    this.decoration,
  })  : maxLength = null,
        obscureText = false,
        isEmail = false,
        isPass = false,
        isNumber = false,
        maxLines = 1;
  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isSelected = false;
  late bool obscureText;

  @override
  void initState() {
    obscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: obscureText,
      focusNode: widget.focusNode,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      textCapitalization: widget.capitalization ?? TextCapitalization.none,
      decoration: widget.decoration ??
          InputDecoration(
              suffixIcon: widget.obscureText
                  ? IconButton(
                      style: IconButton.styleFrom(
                          fixedSize: const Size.square(10)),
                      padding: EdgeInsets.zero,
                      splashRadius: 10,
                      selectedIcon: const Icon(Icons.visibility),
                      isSelected: isSelected,
                      onPressed: () {
                        setState(() {
                          isSelected = !isSelected;
                          obscureText = !obscureText;
                        });
                      },
                      icon: const Icon(Icons.visibility_off))
                  : null,
              label: Text(widget.title),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: scheme.primary),
              )),
      inputFormatters: widget.inputFormatters,
      validator: widget.customValidator ??
          (value) {
            final reg = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$');
            if (value?.isEmpty ?? true) {
              return StringRes.errorEmpty(widget.title);
            } else if (widget.isEmail && !(value?.isEmail ?? false)) {
              return StringRes.errorEmail;
            } else if (widget.isPass && !reg.hasMatch(value!)) {
              return StringRes.errorWeakPass;
            } else if (widget.isNumber &&
                (value?.length != 10 && value.runtimeType is! int)) {
              return StringRes.errorPhone;
            }
            return null;
          },
    );
  }
}

class SearchTextField extends StatelessWidget {
  final EdgeInsets? margin;
  final String title;
  final Key? fieldKey;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextCapitalization? capitalization;
  final String? Function(String? value)? customValidator;
  final List<TextInputFormatter>? inputFormatters;
  final Color? backgroundColor;
  final VoidCallback? onClear;
  const SearchTextField(
      {super.key,
      this.margin,
      required this.title,
      this.fieldKey,
      this.keyboardType,
      this.controller,
      this.focusNode,
      this.capitalization,
      this.customValidator,
      this.backgroundColor,
      this.onClear,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final borderRadius = BorderRadius.circular(Dimens.borderRadiusLarge);

    InputBorder border() {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey[300]!),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius,
      ),
      child: MyTextField._search(
        title: title,
        fieldKey: fieldKey,
        controller: controller,
        keyboardType: keyboardType,
        focusNode: focusNode,
        capitalization: capitalization,
        inputFormatters: inputFormatters,
        customValidator: (value) {
          return null;
        },
        decoration: InputDecoration(
            hintText: title,
            hintStyle: TextStyle(color: scheme.disabled),
            focusedBorder: border(),
            enabledBorder: border(),
            suffixIcon: IconButton(
                onPressed: onClear ?? controller?.clear,
                icon: Icon(
                  Icons.clear,
                  color: scheme.disabled,
                ))),
      ),
    );
  }
}
