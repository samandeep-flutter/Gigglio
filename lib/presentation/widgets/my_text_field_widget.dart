import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigglio/data/utils/dimens.dart';
import 'package:gigglio/services/extension_services.dart';
import '../../data/utils/string.dart';

class MyTextField extends StatefulWidget {
  final Key? fieldKey;
  final String title;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextCapitalization? capitalization;
  final InputDecoration? decoration;
  final bool? expands;
  final int? maxLines;
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
      : expands = false,
        decoration = null;

  const MyTextField._search({
    this.fieldKey,
    required this.title,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.customValidator,
    this.inputFormatters,
    this.decoration,
  })  : capitalization = null,
        maxLength = null,
        expands = false,
        obscureText = false,
        isEmail = false,
        isPass = false,
        isNumber = false,
        maxLines = 1;

  const MyTextField._custom({
    this.fieldKey,
    required this.title,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.capitalization,
    this.customValidator,
    this.inputFormatters,
    this.expands,
    this.maxLines,
    this.decoration,
  })  : maxLength = null,
        obscureText = false,
        isEmail = false,
        isPass = false,
        isNumber = false;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isSelected = false;
  late bool obscureText;
  TextInputType? inputType;

  @override
  void initState() {
    obscureText = widget.obscureText;
    if (widget.isEmail) {
      inputType = widget.keyboardType ?? TextInputType.emailAddress;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? inputType,
      obscureText: obscureText,
      focusNode: widget.focusNode,
      expands: widget.expands ?? false,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      autocorrect: false,
      textAlignVertical: (widget.expands ?? false || (widget.maxLines ?? 1) > 1)
          ? TextAlignVertical.top
          : null,
      textCapitalization: widget.capitalization ?? TextCapitalization.none,
      decoration: widget.decoration ??
          InputDecoration(
            contentPadding: EdgeInsets.all(Dimens.sizeDefault),
            suffixIcon: widget.obscureText
                ? IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: Dimens.sizeSmall,
                    color: context.scheme.textColorLight,
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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimens.borderDefault)),
          ),
      inputFormatters: widget.inputFormatters,
      validator: widget.customValidator ??
          (value) {
            final reg = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
            if (value?.isEmpty ?? true) {
              return StringRes.errorEmpty(widget.title);
            } else if (widget.isEmail && !(value?.isEmail ?? false)) {
              return StringRes.errorEmail;
            } else if (widget.isPass && !reg.hasMatch(value!)) {
              return StringRes.errorCriteria;
            } else if (widget.isNumber &&
                (value?.length != 10 && value.runtimeType is! int)) {
              return StringRes.errorPhone;
            }
            return null;
          },
    );
  }
}

class SearchTextField extends StatefulWidget {
  final EdgeInsets? margin;
  final String title;
  final Key? fieldKey;
  final bool compact;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String? value)? customValidator;
  final List<TextInputFormatter>? inputFormatters;
  final Color? backgroundColor;
  final bool showClear;
  final VoidCallback? onClear;
  const SearchTextField(
      {super.key,
      this.margin,
      required this.title,
      this.fieldKey,
      this.keyboardType,
      this.controller,
      this.compact = false,
      this.focusNode,
      this.customValidator,
      this.backgroundColor,
      this.onClear,
      this.showClear = true,
      this.inputFormatters});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  late double vertPadding;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    if (widget.showClear) {
      _controller.addListener(onChange);
    }
    vertPadding = widget.compact ? Dimens.sizeSmall : Dimens.sizeDefault;
    super.initState();
  }

  void onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Container(
      margin: widget.margin,
      height: widget.compact ? Dimens.sizeExtraDoubleLarge : null,
      alignment: Alignment.center,
      child: MyTextField._search(
        title: widget.title,
        fieldKey: widget.fieldKey,
        controller: _controller,
        keyboardType: widget.keyboardType,
        focusNode: widget.focusNode,
        inputFormatters: widget.inputFormatters,
        customValidator: (value) {
          return null;
        },
        decoration: InputDecoration(
            hintText: widget.title,
            contentPadding: EdgeInsets.symmetric(
                horizontal: Dimens.sizeDefault, vertical: vertPadding),
            hintStyle: TextStyle(color: scheme.disabled),
            focusedBorder: border,
            enabledBorder: border,
            fillColor: widget.backgroundColor,
            filled: widget.backgroundColor != null,
            prefixIcon: Icon(Icons.search, color: scheme.disabled),
            suffixIcon: widget.showClear && _controller.text.isNotEmpty
                ? IconButton(
                    onPressed: widget.onClear ?? widget.controller?.clear,
                    icon: Icon(Icons.clear, color: scheme.disabled))
                : null),
      ),
    );
  }

  InputBorder get border {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimens.borderDefault),
      borderSide: BorderSide(color: context.scheme.backgroundDark),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final EdgeInsets? margin;
  final String title;
  final Key? fieldKey;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? expands;
  final int? maxLines;
  final TextCapitalization? capitalization;
  final String? Function(String? value)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? defaultBorder;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const CustomTextField({
    super.key,
    this.margin,
    required this.title,
    this.fieldKey,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.expands,
    this.maxLines,
    this.capitalization,
    this.validator,
    this.inputFormatters,
    this.backgroundColor,
    this.defaultBorder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final radius = BorderRadius.circular(Dimens.borderDefault);

    InputBorder inputBorder() {
      return OutlineInputBorder(
        borderRadius: borderRadius ?? radius,
        borderSide: BorderSide(color: backgroundColor ?? Colors.white),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: borderRadius ?? radius),
      child: MyTextField._custom(
        title: title,
        fieldKey: fieldKey,
        keyboardType: keyboardType,
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        expands: expands ?? false,
        capitalization: capitalization,
        customValidator: validator ?? (value) => null,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: title,
          contentPadding: EdgeInsets.all(Dimens.sizeDefault),
          focusedBorder: defaultBorder ?? false
              ? OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: scheme.primary),
                )
              : inputBorder(),
          enabledBorder: defaultBorder ?? false
              ? OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(
                    color: scheme.disabled,
                    width: 1.5,
                  ))
              : inputBorder(),
        ),
      ),
    );
  }
}
