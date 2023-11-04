import 'package:driver_customer_app/src/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';

// ignore: must_be_immutable
class CustomLocationPickerWidget extends StatefulWidget {
  TextEditingController? controller;
  final bool autofocus;
  final String? labelText;
  final TextStyle? labelStyle;
  final String? hintText;
  final bool isRequired;
  final Color? backgroundColor;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final Widget? prefixIcon;
  final Function(DetailsResult)? onSuggestionSelected;
  final Function(String?)? validator;
  final void Function()? onTap;
  CustomLocationPickerWidget(
      {Key? key,
      this.autofocus = false,
      this.isRequired = true,
      this.labelText,
      this.labelStyle,
      this.hintText,
      this.backgroundColor,
      this.onSuggestionSelected,
      this.validator,
      this.onTap,
      this.focusedErrorBorder,
      this.errorBorder,
      this.enabledBorder,
      this.focusedBorder,
      this.prefixIcon,
      this.controller})
      : super(key: key);

  @override
  State<CustomLocationPickerWidget> createState() =>
      _CustomLocationPickerWidgetState();
}

class _CustomLocationPickerWidgetState
    extends State<CustomLocationPickerWidget> {
  DetailsResult? selected;
  bool searching = false;
  TextEditingController controller = TextEditingController();
  final _focusNode = FocusNode();
  late final GooglePlace googlePlace;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(setting.value.googleMapsKey ?? '');
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && selected == null && !searching) {
        controller.text = '';
      } else if (selected != null &&
          controller.text != selected!.formattedAddress) {
        controller.text = selected!.formattedAddress ?? '';
      }
    });
  }

  Future<DetailsResult?> getDetails(String placeId) async {
    var result = await this
        .googlePlace
        .details
        .get(placeId, language: Localizations.localeOf(context).languageCode);
    if (result != null && result.result != null && mounted) {
      setState(() {
        selected = result.result;
      });
      controller.text = selected!.formattedAddress ?? selected!.name ?? '';
      return selected;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      widget.controller = controller;
    }
    return TypeAheadFormField(
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      textFieldConfiguration: TextFieldConfiguration(
          onTap: widget.onTap,
          controller: widget.controller,
          autofocus: widget.autofocus,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: widget.prefixIcon != null
                ? BoxConstraints(
                    minWidth: 30,
                    minHeight: 10,
                  )
                : null,
            prefix: searching
                ? Padding(
                    padding: const EdgeInsets.only(right: 5, top: 5),
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : Icon(
                    Icons.abc_outlined,
                    color: Colors.red,
                  ),
            label: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: widget.labelText,
                    style: widget.labelStyle ??
                        TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                  ),
                  if (widget.isRequired)
                    WidgetSpan(
                      child: Text(
                        ' *',
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    ),
                ],
              ),
            ),
            isDense: true,
            hintText: widget.hintText,
            fillColor: widget.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            hintStyle: const TextStyle(color: Colors.grey),
            errorStyle: rubikBold,
            errorMaxLines: 2,
            focusedErrorBorder: widget.focusedErrorBorder ??
                UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).errorColor, width: 1),
                ),
            errorBorder: widget.errorBorder ??
                UnderlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                  borderSide:
                      BorderSide(color: Theme.of(context).errorColor, width: 2),
                ),
            enabledBorder: widget.enabledBorder ??
                UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 0.7),
                ),
            focusedBorder: widget.focusedBorder ??
                UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
            filled: true,
          ),
          cursorColor: Theme.of(context).primaryColor,
          focusNode: _focusNode),
      noItemsFoundBuilder: (value) {
        return Container(
          color: Theme.of(context).highlightColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.PADDING_SIZE_DEFAULT,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.noResultsFound,
                  style: khulaBold.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.isNotEmpty) {
          var googlePlace = GooglePlace(setting.value.googleMapsKey ?? '');
          var result = await googlePlace.autocomplete.get(pattern,
              language: Localizations.localeOf(context).languageCode);
          return result?.predictions?.take(5).toList() ?? [];
        }
        return [];
      },
      itemBuilder: (context, suggestion) {
        suggestion = suggestion as AutocompletePrediction;
        return ListTile(
          tileColor: Theme.of(context).highlightColor,
          title: Text(
            suggestion.description ?? '',
            style: kSubtitleStyle.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
      onSuggestionSelected: (suggestion) async {
        setState(() => searching = true);
        AutocompletePrediction sug = suggestion as AutocompletePrediction;
        await getDetails(sug.placeId ?? '').then((value) {
          if (value != null) {
            if (widget.onSuggestionSelected != null) {
              widget.onSuggestionSelected!(value);
            }
          } else {
            widget.controller!.text = '';
          }
          setState(() => searching = false);
        }).catchError((onError) {
          setState(() => searching = false);
        });
      },
    );
  }
}
