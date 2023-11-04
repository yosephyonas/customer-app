import 'package:flutter/material.dart';

import '../../helper/styles.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final String? actionText;
  final Icon? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? actionColor;
  final Function? action;

  const CustomToast(
      {Key? key,
      required this.text,
      this.actionText,
      this.icon,
      this.backgroundColor,
      this.textColor,
      this.actionColor,
      this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: icon,
                )
              : const SizedBox(),
          Flexible(
            fit: actionText != null ? FlexFit.tight : FlexFit.loose,
            child: Text(
              text,
              style: khulaRegular.copyWith(
                  color: textColor ?? Theme.of(context).colorScheme.background),
            ),
          ),
          if (actionText != null)
            InkWell(
              onTap: () {
                if (action != null) {
                  action!();
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  actionText!,
                  style: khulaBold.copyWith(
                      color: actionColor ?? Theme.of(context).highlightColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
