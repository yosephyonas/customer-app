import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:driver_customer_app/src/helper/dimensions.dart';
import 'package:driver_customer_app/src/helper/styles.dart';
import 'package:driver_customer_app/src/views/widgets/cancel_ride_confirmation_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:driver_customer_app/src/helper/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../models/ride.dart';

class RidePendingWidget extends StatelessWidget {
  final Ride ride;
  final Function onCancelRide;
  RidePendingWidget(this.ride, this.onCancelRide, {Key? key}) : super(key: key);

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: true,
          child: GoogleMap(
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) async {
              String style = await DefaultAssetBundle.of(context)
                  .loadString(Assets.mapStyle);
              controller.setMapStyle(style);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(ride.boardingLocation!.latitude,
                  ride.boardingLocation!.longitude),
              zoom: 15,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: AvatarGlow(
              glowColor: Colors.black,
              endRadius: 130,
              repeatPauseDuration: const Duration(milliseconds: 50),
              animate: true,
              child: Material(
                elevation: 8.0,
                shape: CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: Image.asset(
                    Assets.placeholderUser,
                    height: 30,
                  ),
                  radius: 20,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Card(
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: AutoSizeText(
                                AppLocalizations.of(context)!.lookingForDriver,
                                style: kTitleStyle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      CancelRideConfirmationDialog(
                                    onConfirmed: () async {
                                      Navigator.of(context).pop();
                                      await onCancelRide();
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  AppLocalizations.of(context)!.cancelRide,
                                  textAlign: TextAlign.center,
                                  style: khulaSemiBold.copyWith(
                                    color: Colors.red.withOpacity(.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
