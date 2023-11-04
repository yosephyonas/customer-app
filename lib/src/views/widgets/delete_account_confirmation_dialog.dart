import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';

class DeleteAccountConfirmationDialog extends StatelessWidget {
  final Function onConfirmed;
  bool loading = false;
  DeleteAccountConfirmationDialog({Key? key, required this.onConfirmed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.deletingYourAccont,
                      style: kTitleStyle.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(height: 30),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.deleteAccount,
                      style: kTitleStyle.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_LARGE,
                          vertical: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                      child: Text(
                        AppLocalizations.of(context)!
                            .reallyWantDeleteAccontDataWillBeLost,
                        style: kSubtitleStyle.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(height: 0, color: Theme.of(context).hintColor),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                setState(() => loading = true);
                                await onConfirmed();
                                setState(() => loading = false);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(
                                    Dimensions.PADDING_SIZE_SMALL),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .errorColor
                                      .withOpacity(.3),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.yes,
                                  style: rubikBold.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                            width: 0,
                            color: Theme.of(context).hintColor,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(
                                    Dimensions.PADDING_SIZE_SMALL),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.no,
                                  style: rubikBold.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
