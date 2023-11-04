import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:driver_customer_app/src/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final String? initialValue;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isDateOfBirth;
  final bool isBorder;
  final bool isRequired;
  final Function? validator;
  final Function? onSave;
  final Function? onChange;
  final VoidCallback calendarTap;
  final AutovalidateMode validateMode;
  final List<TextInputFormatter> inputFormatters;
  TextEditingController? controller = TextEditingController();
  final Widget? prefixIcon;
  final BoxConstraints prefixIconConstraints;
  final Widget? suffixIcon;
  final BoxConstraints suffixIconConstraints;
  final bool enabled;
  final String errorText;
  final EdgeInsetsGeometry? contentPadding;
  final Color? color;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextStyle? style;
  final bool readOnly;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final void Function()? onTap;
  final TextCapitalization? textCapitalization;

  CustomTextFormField(
      {Key? key,
      this.hintText = '',
      this.labelText = '',
      this.initialValue,
      this.validator,
      this.onSave,
      this.onChange,
      this.focusNode,
      this.nextFocus,
      this.readOnly = false,
      this.validateMode = AutovalidateMode.onUserInteraction,
      this.inputType = TextInputType.text,
      this.inputAction = TextInputAction.next,
      this.maxLines = 1,
      VoidCallback? calendarTap,
      this.isDateOfBirth = false,
      this.isCountryPicker = false,
      this.isBorder = true,
      this.isRequired = false,
      this.isPassword = false,
      this.inputFormatters = const [],
      this.controller,
      this.prefixIcon,
      this.prefixIconConstraints =
          const BoxConstraints(minWidth: 0, minHeight: 0),
      this.suffixIcon,
      this.suffixIconConstraints =
          const BoxConstraints(minWidth: 0, minHeight: 0),
      this.errorText = "",
      this.contentPadding,
      this.color,
      this.enabled = true,
      this.hintStyle,
      this.labelStyle,
      this.floatingLabelBehavior,
      this.style,
      this.onTap,
      this.focusedErrorBorder,
      this.errorBorder,
      this.enabledBorder,
      this.focusedBorder,
      this.textCapitalization})
      : calendarTap = calendarTap ?? (() {}),
        super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: widget.onTap,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode ?? null,
      style: widget.style ??
          TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
            fontSize: 18,
          ),
      textInputAction: widget.inputAction,
      keyboardType: widget.inputType,
      obscureText: widget.isPassword ? _obscureText : false,
      autovalidateMode: widget.validateMode,
      readOnly: widget.readOnly,
      onSaved: (newValue) =>
          widget.onSave != null ? widget.onSave!(newValue) : null,
      onChanged: (newValue) =>
          widget.onChange != null ? widget.onChange!(newValue) : null,
      inputFormatters: widget.inputFormatters,
      controller: widget.controller,
      initialValue: widget.initialValue,
      onFieldSubmitted: (v) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
      },
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        label: widget.labelText.isNotEmpty || !widget.enabled
            ? Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                        text:
                            widget.labelText.isEmpty ? null : widget.labelText,
                        style: widget.labelStyle ??
                            TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).primaryColor)),
                    widget.isRequired
                        ? WidgetSpan(
                            child: Text(
                              ' *',
                              style: TextStyle(
                                  color: Theme.of(context).errorColor),
                            ),
                          )
                        : !widget.enabled
                            ? WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left:
                                          Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  child: Icon(
                                    Icons.lock,
                                    size: 15,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              )
                            : const WidgetSpan(child: SizedBox()),
                  ],
                ),
              )
            : SizedBox(),
        contentPadding: widget.contentPadding ?? const EdgeInsets.all(12),
        isDense: true,
        hintText: widget.hintText,
        fillColor: widget.enabled
            ? widget.color ??
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1)
            : Theme.of(context).hintColor.withOpacity(0.2),
        hintStyle: widget.hintStyle ??
            TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 17,
            ),
        floatingLabelBehavior: widget.floatingLabelBehavior,
        errorStyle: rubikBold,
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: widget.prefixIconConstraints,
        errorText: widget.errorText.isEmpty ? null : widget.errorText,
        errorMaxLines: 2,
        focusedErrorBorder: widget.isBorder
            ? widget.focusedErrorBorder ??
                UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).errorColor, width: 1),
                )
            : InputBorder.none,
        disabledBorder: widget.isBorder
            ? UnderlineInputBorder(
                borderSide: BorderSide(color: (Colors.grey[400])!, width: 0.7),
              )
            : InputBorder.none,
        errorBorder: !widget.enabled
            ? widget.errorBorder ??
                UnderlineInputBorder(
                  borderSide: BorderSide(color: (Colors.grey[400])!, width: 2),
                )
            : widget.isBorder
                ? UnderlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                    borderSide: BorderSide(
                        color: Theme.of(context).errorColor, width: 2),
                  )
                : InputBorder.none,
        enabledBorder: widget.isBorder
            ? widget.enabledBorder ??
                UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: setting.value.theme == AdaptiveThemeMode.light
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).highlightColor,
                      width: 1),
                )
            : InputBorder.none,
        focusedBorder: widget.isBorder
            ? widget.focusedBorder ??
                UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: setting.value.theme == AdaptiveThemeMode.light
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).highlightColor,
                      width: 1.5),
                )
            : InputBorder.none,
        filled: true,
        suffixIcon: widget.isPassword || widget.isDateOfBirth
            ? widget.isPassword
                ? IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(.75)),
                    onPressed: _toggle)
                : IconButton(
                    icon: Icon(Icons.calendar_today,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(.75)),
                    onPressed: widget.calendarTap)
            : widget.suffixIcon ?? null,
        suffixIconConstraints: widget.suffixIconConstraints,
      ),
      cursorColor: Theme.of(context).primaryColor,
      validator: (value) =>
          widget.validator != null ? widget.validator!(value) : null,
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
