import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';

class CancelRideConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirmed;
  const CancelRideConfirmationDialog({Key? key, required this.onConfirmed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_LARGE,
                vertical: Dimensions.PADDING_SIZE_EXTRA_LARGE * 1.5),
            child: Text(AppLocalizations.of(context)!.reallyWantCancelRide,
                style: rubikBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center),
          ),
          Divider(height: 0, color: Theme.of(context).hintColor),
          Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  onConfirmed();
                },
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor.withOpacity(0.1),
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
              )),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding:
                        const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.no,
                      style: rubikBold.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
