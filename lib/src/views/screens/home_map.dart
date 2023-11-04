import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:driver_customer_app/src/controllers/ride_controller.dart';
import 'package:driver_customer_app/src/helper/assets.dart';
import 'package:driver_customer_app/src/helper/helper.dart';
import 'package:driver_customer_app/src/models/driver.dart';
import 'package:driver_customer_app/src/models/vehicle_type.dart';
import 'package:driver_customer_app/src/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomeMapScreen extends StatefulWidget {
  final Function? locationChanged;
  const HomeMapScreen({this.locationChanged, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeMapScreenState();
  }
}

class HomeMapScreenState extends StateMVC<HomeMapScreen> {
  late RideController _rideCon;
  Timer? timer;
  final Set<Marker> _markers = {};
  Map<PolylineId, Polyline> polylines = {};
  late GoogleMapController _controller;
  Location _location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  LocationData? _currentLocation;
  Map<String, BitmapDescriptor> _customIcons = {
    'default': BitmapDescriptor.defaultMarker
  };
  PolylinePoints polylinePoints = PolylinePoints();
  LatLng _initialcameraposition = LatLng(
    -14.6825207,
    -49.7332467,
  );

  HomeMapScreenState() : super(RideController()) {
    _rideCon = controller as RideController;
  }

  Future<void> updatDriversAround() async {
    await _rideCon
        .doGetDriversAround(
            _currentLocation!.latitude!, _currentLocation!.longitude!)
        .then((value) {
      _rideCon.driversAround.forEach((driver) {
        addDriverMarker(driver);
      });
    });
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
        _customIcons
            .addAll({vehicle.id: BitmapDescriptor.fromBytes(markerIcon)});
      });
    }
  }

  Future<void> setMapStyle() async {
    String style =
        await DefaultAssetBundle.of(context).loadString(Assets.mapStyle);
    _controller.setMapStyle(style);
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    setMapStyle();
    getInitialLocation();
  }

  Future<void> addDriverMarker(Driver driver) async {
    try {
      if (driver.vehicleType != null &&
          !_customIcons.containsKey(driver.vehicleType!.id)) {
        await setVehicleIcon(driver.vehicleType!);
      }
    } catch (e) {}
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId("driver-${driver.id}"),
            position: LatLng(
              driver.lat!,
              driver.lng!,
            ),
            icon: driver.vehicleType != null &&
                    _customIcons.containsKey(driver.vehicleType!.id)
                ? _customIcons[driver.vehicleType!.id]!
                : _customIcons['default']!),
      );
    });
  }

  Future<void> addLocationMarker(LatLng? pickup, LatLng? destination) async {
    setState(() {
      if (pickup != null) {
        _markers.add(
          Marker(
            markerId: MarkerId("marker-destination"),
            position: pickup,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      } else {
        _markers.removeWhere(
            (element) => element.markerId == MarkerId("marker-destination"));
      }
      if (destination != null) {
        _markers.add(
          Marker(
            markerId: MarkerId("marker-pickup"),
            position: destination,
          ),
        );
      } else {
        _markers.removeWhere(
            (element) => element.markerId == MarkerId("marker-pickup"));
      }
    });
    if (pickup != null &&
        destination != null &&
        setting.value.googleMapsKey != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          setting.value.googleMapsKey!,
          PointLatLng(pickup.latitude, pickup.longitude),
          PointLatLng(destination.latitude, destination.longitude),
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
    } else {
      setState(() {
        polylines.clear();
      });
    }
  }

  Future<void> zoomMarkers(LatLng? pickup, LatLng? destination) async {
    if (pickup != null && destination != null) {
      _controller.moveCamera(
        CameraUpdate.newLatLngBounds(
          Helper.getLatLngBounds(pickup, destination),
          150,
        ),
      );
    } else if (pickup != null) {
      _controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: pickup, zoom: await _controller.getZoomLevel()),
        ),
      );
    } else if (destination != null) {
      _controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: destination, zoom: await _controller.getZoomLevel()),
        ),
      );
    } else if (_currentLocation?.latitude != null &&
        _currentLocation?.longitude != null) {
      _controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  _currentLocation!.latitude!, _currentLocation!.longitude!),
              zoom: await _controller.getZoomLevel()),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    locationSubscription.cancel();
    super.dispose();
  }

  Future<void> getInitialLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    await _location.getLocation().then((_locationData) {
      setState(() {
        _currentLocation = _locationData;
      });
      if (widget.locationChanged != null) {
        widget.locationChanged!(_currentLocation);
      }
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(_locationData.latitude!, _locationData.longitude!),
              zoom: 16),
        ),
      );
      updatDriversAround().then((value) {
        timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          updatDriversAround().catchError((onError) {});
        });
      });
    });
    locationSubscription = _location.onLocationChanged.listen((_location) {
      setState(() {
        _currentLocation = _location;
        if (widget.locationChanged != null) {
          widget.locationChanged!(_currentLocation);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      markers: _markers,
      polylines: Set<Polyline>.of(polylines.values),
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _initialcameraposition,
        zoom: 4.82,
      ),
    );
  }
}
