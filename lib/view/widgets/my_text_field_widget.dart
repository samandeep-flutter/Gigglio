import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../model/utils/string.dart';

class MyTextField extends StatefulWidget {
  final Key? fieldKey;
  final String title;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextCapitalization? capitalization;
  final int maxLines;
  final int? maxLength;
  final bool isEmail;
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
      this.customValidator,
      this.inputFormatters,
      this.obscureText = false});
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
    ColorScheme scheme = Theme.of(context).colorScheme;
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: obscureText,
      focusNode: widget.focusNode,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      textCapitalization: widget.capitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
          suffixIcon: widget.obscureText
              ? IconButton(
                  style: IconButton.styleFrom(fixedSize: const Size.square(10)),
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
            if (value?.isEmpty ?? true) {
              return StringRes.errorEmpty(widget.title);
            } else if (widget.isEmail && !(value?.isEmail ?? false)) {
              return StringRes.errorEmail;
            } else if (widget.isNumber &&
                (value?.length != 10 && value.runtimeType is! int)) {
              return StringRes.errorPhone;
            }
            return null;
          },
    );
  }
}
