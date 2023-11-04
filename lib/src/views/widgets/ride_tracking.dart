import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:driver_customer_app/src/helper/dimensions.dart';
import 'package:driver_customer_app/src/models/status_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../controllers/ride_controller.dart';
import '../../helper/assets.dart';
import '../../helper/styles.dart';
import '../../models/ride.dart';
import '../../models/vehicle_type.dart';
import '../../repositories/setting_repository.dart';

class RideTrackingWidget extends StatefulWidget {
  final Ride ride;

  RideTrackingWidget({Key? key, required this.ride}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RideTrackingWidgetState();
  }
}

class RideTrackingWidgetState extends StateMVC<RideTrackingWidget> {
  Completer<GoogleMapController> _mapsController = Completer();
  bool locked = true;
  Timer? timer;
  Map<PolylineId, Polyline> polylines = {};
  late RideController _con;
  BitmapDescriptor icon = BitmapDescriptor.defaultMarkerWithHue(30);

  RideTrackingWidgetState() : super(RideController()) {
    _con = controller as RideController;
  }

  Future<void> setVehicleIcon(VehicleType vehicle) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(vehicle.picture!.url);
    img.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));
    final imageInfo = await completer.future;
    ByteData? data =
        await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: 200);
      ui.FrameInfo fi = await codec.getNextFrame();
      final Uint8List markerIcon =
          (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List();
      setState(() {
        icon = BitmapDescriptor.fromBytes(markerIcon);
      });
    }
  }

  Future<void> animateToMarker() async {
    if (_con.ride!.driver?.lat != null &&
        _con.ride!.driver?.lng != null &&
        locked != true) {
      final GoogleMapController controller = await _mapsController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_con.ride!.driver!.lat!, _con.ride!.driver!.lng!),
            zoom: await controller.getZoomLevel(),
          ),
        ),
      );
    }
  }

  void updateDriverLocation() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _con.doUpdateDriverLocation(_con.ride!).then((changed) {
        if (changed) {
          animateToMarker();
        }
      }).catchError((onError) {});
    });
  }

  Future<void> addRoutePolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        setting.value.googleMapsKey!,
        PointLatLng(_con.ride!.boardingLocation!.latitude,
            _con.ride!.boardingLocation!.longitude),
        PointLatLng(_con.ride!.destinationLocation!.latitude,
            _con.ride!.destinationLocation!.longitude),
        travelMode: TravelMode.driving,
        wayPoints: []);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      polylines.clear();
      PolylineId id = PolylineId("poly");
      Polyline polyline = Polyline(
          polylineId: id,
          width: 8,
          color: Theme.of(context).primaryColor,
          points: polylineCoordinates);
      polylines[id] = polyline;
    });
  }

  @override
  void initState() {
    _con.ride = widget.ride;
    setVehicleIcon(_con.ride!.driver!.vehicleType!);
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerMove: (e) {
            setState(() => locked = false);
          },
          child: GoogleMap(
            polylines: Set<Polyline>.of(polylines.values),
            markers: Set<Marker>.of(
              [
                Marker(
                  markerId: MarkerId('driver'),
                  position: LatLng(
                    _con.ride?.driver?.lat ?? 0,
                    _con.ride?.driver?.lng ?? 0,
                  ),
                  icon: icon,
                ),
                Marker(
                  markerId: MarkerId('boarding'),
                  position: LatLng(
                    _con.ride?.boardingLocation?.latitude ?? 0,
                    _con.ride?.boardingLocation?.longitude ?? 0,
                  ),
                ),
                Marker(
                  markerId: MarkerId('destination'),
                  position: LatLng(
                    _con.ride?.destinationLocation?.latitude ?? 0,
                    _con.ride?.destinationLocation?.longitude ?? 0,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: 40.0,
            ),
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  _con.ride!.driver?.lat ?? 0, _con.ride!.driver?.lng ?? 0),
              zoom: 16.5,
            ),
            onMapCreated: (GoogleMapController controller) async {
              _mapsController.complete(controller);
              String style = await DefaultAssetBundle.of(context)
                  .loadString(Assets.mapStyle);
              controller.setMapStyle(style);
              addRoutePolyline();
              updateDriverLocation();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: [
                if (!locked)
                  FloatingActionButton(
                    heroTag: "buttonLockTracking",
                    onPressed: () {
                      animateToMarker();
                      setState(() => locked = true);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      FontAwesomeIcons.locationArrow,
                      size: 36.0,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_con.ride!.rideStatus == StatusEnum.accepted)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            AppLocalizations.of(context)!
                                .driverHeadingYourLocation(
                                    _con.ride?.driver?.user?.name != null
                                        ? (_con.ride!.driver!.user!.name)
                                            .split(' ')
                                            .first
                                        : AppLocalizations.of(context)!.driver),
                            style: kTitleStyle.copyWith(
                              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          SizedBox(height: 5),
                          AutoSizeText(
                            '${AppLocalizations.of(context)!.brand}: ${_con.ride?.driver?.brand ?? ''}',
                            style: kTitleStyle.copyWith(
                                fontSize: Dimensions.FONT_SIZE_LARGE),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            '${AppLocalizations.of(context)!.model}: ${_con.ride?.driver?.model ?? ''}',
                            style: kTitleStyle.copyWith(
                                fontSize: Dimensions.FONT_SIZE_LARGE),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            '${AppLocalizations.of(context)!.plate}: ${_con.ride?.driver?.plate ?? ''}',
                            style: kTitleStyle.copyWith(
                                fontSize: Dimensions.FONT_SIZE_LARGE),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        else if (_con.ride!.rideStatus == StatusEnum.in_progress)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: AutoSizeText(
                            AppLocalizations.of(context)!.rideInProgress,
                            style: kTitleStyle.copyWith(
                              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
