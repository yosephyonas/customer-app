import 'dart:async';

import 'package:driver_customer_app/src/models/payment_gateway_enum.dart';
import 'package:driver_customer_app/src/views/screens/payment/mercado_pago.dart';
import 'package:driver_customer_app/src/views/screens/payment/razorpay.dart';
import 'package:driver_customer_app/src/views/screens/payment/stripe.dart';
import 'package:driver_customer_app/src/views/screens/ride/ride_pending.dart';
import 'package:driver_customer_app/src/views/widgets/ride_details.dart';
import 'package:driver_customer_app/src/views/widgets/ride_tracking.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../controllers/ride_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/styles.dart';
import '../../../models/ride.dart';
import '../../../models/screen_argument.dart';
import '../../../models/status_enum.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/ride_address.dart';
import '../payment/flutterwave.dart';
import '../payment/paypal.dart';

class RideScreen extends StatefulWidget {
  final String rideId;
  final bool showButtons;
  const RideScreen({Key? key, required this.rideId, this.showButtons = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RideScreenState();
  }
}

class RideScreenState extends StateMVC<RideScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RideTrackingWidgetState> trackingKey =
      GlobalKey<RideTrackingWidgetState>();
  late RideController _con;
  int currentTab = 0;
  late FToast fToast;
  Timer? timerStatus;

  RideScreenState() : super(RideController()) {
    _con = controller as RideController;
  }

  @override
  void initState() {
    getRide();
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    if (timerStatus != null) {
      timerStatus!.cancel();
    }
    super.dispose();
  }

  Future<void> getRide() async {
    if (timerStatus != null) {
      timerStatus!.cancel();
    }
    await _con.doGetRide(widget.rideId).then((Ride _ride) {
      updateStatus();
    }).catchError((_error) {
      fToast.removeCustomToast();
      fToast.showToast(
        child: CustomToast(
          backgroundColor: Colors.red,
          icon: Icon(Icons.close, color: Colors.white),
          text: _error.toString(),
          textColor: Colors.white,
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    });
  }

  void updateStatus() {
    timerStatus = Timer.periodic(const Duration(seconds: 10), (timer) {
      final StatusEnum tmpRideStatus = _con.ride!.rideStatus!;
      _con.doCheckRideStatus(_con.ride!).then((value) {
        if (tmpRideStatus == StatusEnum.waiting &&
            tmpRideStatus != _con.ride!.rideStatus) {
          Navigator.pushReplacementNamed(
            context,
            '/Ride',
            arguments: ScreenArgument(
              {
                'rideId': _con.ride!.id,
              },
            ),
          );
        } else if (tmpRideStatus != _con.ride!.rideStatus) {
          getRide();
        }
      }).catchError((onError) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: RichText(
          text: _con.ride != null
              ? TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context)!.ride} #${_con.ride!.id} - ',
                      style: khulaSemiBold.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: StatusEnumHelper.description(
                          _con.ride!.rideStatus, context),
                      style: khulaBold.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                )
              : const TextSpan(),
        ),
        actions: [
          if (_con.ride != null &&
              (_con.ride!.rideStatus == StatusEnum.accepted ||
                  _con.ride!.rideStatus == StatusEnum.in_progress))
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/Chat',
                  arguments: ScreenArgument({'rideId': _con.ride!.id}),
                );
              },
              child: Icon(
                Icons.chat,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/RecentRides');
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      bottomNavigationBar:
          _con.ride != null && _con.ride!.rideStatus == StatusEnum.waiting
              ? Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(color: Colors.black54, blurRadius: 10)
                  ]),
                  child: BottomAppBar(
                    child: Container(
                      height: 80,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Column(
                              children: [
                                if (_con.ride!.paymentGateway ==
                                    PaymentGatewayEnum.stripe)
                                  StripePaymentWidget(_con.ride!)
                                else if (_con.ride!.paymentGateway ==
                                    PaymentGatewayEnum.mercado_pago)
                                  MercadoPagoPaymentWidget(_con.ride!)
                                else if (_con.ride!.paymentGateway ==
                                    PaymentGatewayEnum.paypal)
                                  PaypalPaymentWidget(_con.ride!)
                                else if (_con.ride!.paymentGateway ==
                                    PaymentGatewayEnum.flutterwave)
                                  FlutterwavePaymentWidget(_con.ride!)
                                else if (_con.ride!.paymentGateway ==
                                    PaymentGatewayEnum.razorpay)
                                  RazorpayPaymentWidget(_con.ride!)
                              ],
                            )),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
      body: _con.loading
          ? const Center(child: CircularProgressIndicator())
          : _con.ride == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.rideNotFound,
                      style: khulaBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: Dimensions.PADDING_SIZE_LARGE,
                        left: Dimensions.PADDING_SIZE_LARGE,
                        right: Dimensions.PADDING_SIZE_LARGE,
                      ),
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: TextButton.icon(
                        onPressed: () async {
                          getRide();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).highlightColor,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.tryAgain,
                          style: poppinsSemiBold.copyWith(
                              color: Theme.of(context).highlightColor,
                              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                        ),
                      ),
                    ),
                  ],
                )
              : _con.ride!.rideStatus == StatusEnum.pending
                  ? RidePendingWidget(_con.ride!, () async {
                      await _con.doCancelRide(_con.ride!).then((value) {
                        Navigator.of(context)
                            .pushReplacementNamed('/RecentRides');
                      });
                    })
                  : _con.ride!.rideStatus == StatusEnum.accepted ||
                          _con.ride!.rideStatus == StatusEnum.in_progress
                      ? RideTrackingWidget(key: trackingKey, ride: _con.ride!)
                      : Column(
                          children: [
                            SizedBox(
                              height: 275,
                              child: RideAddressWidget(
                                ride: _con.ride!,
                                showHeader: false,
                              ),
                            ),
                            Expanded(
                              child: RideDetailsWidget(ride: _con.ride!),
                            ),
                          ],
                        ),
      // Container(
      //     height: 400,
      //     child: RideAddressWidget(ride: _con.ride!))
    );
  }
}
