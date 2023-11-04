import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/address.dart';
import '../../models/ride.dart';

class RideAddressWidget extends StatefulWidget {
  final Ride ride;
  final bool showHeader;

  RideAddressWidget({Key? key, required this.ride, this.showHeader = true})
      : super(key: key);

  @override
  State<RideAddressWidget> createState() => _RideAddressWidgetState();
}

class _RideAddressWidgetState extends State<RideAddressWidget> {
  void openAddress(Address address) {
    MapsLauncher.launchCoordinates(address.latitude, address.longitude,
        address.name + ' - ' + (address.number ?? ''));
  }

  Widget generateDecoration(Widget conteudo) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            blurRadius: 5,
          )
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: conteudo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              AppLocalizations.of(context)!.clickOnAdressOpenInMap,
              textAlign: TextAlign.center,
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).primaryColor),
            ),
          ),
        InkWell(
          onTap: () {
            openAddress(widget.ride.boardingLocation!);
          },
          child: generateDecoration(
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
                vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
              ),
              title: Text(
                '${AppLocalizations.of(context)!.boardingPlace}:',
                style: khulaBold.copyWith(
                    fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                    color: Theme.of(context).primaryColor),
              ),
              subtitle: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.FONT_SIZE_EXTRA_SMALL,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                ),
                child: AutoSizeText(
                  ((widget.ride.boardingLocation?.formattedAddress) ?? '') +
                      ' - ' +
                      (widget.ride.boardingLocation?.number ?? ''),
                  minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                  style: khulaRegular.copyWith(
                    fontSize: Dimensions.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        generateDecoration(
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.FONT_SIZE_EXTRA_SMALL,
              vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
            ),
            title: Text(
              '${AppLocalizations.of(context)!.destination}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                  color: Theme.of(context).primaryColor),
              maxLines: 2,
            ),
            subtitle: InkWell(
              onTap: () {
                openAddress(widget.ride.destinationLocation!);
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: Dimensions.PADDING_SIZE_SMALL,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                    width: 1,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
                    vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
                  ),
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.locationArrow),
                    ],
                  ),
                  iconColor: Theme.of(context).primaryColor,
                  minLeadingWidth: 0,
                  title: AutoSizeText(
                    '${widget.ride.destinationLocation!.formattedAddress + ' - ' + (widget.ride.destinationLocation!.number ?? '')}',
                    style: khulaRegular.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
