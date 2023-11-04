import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:driver_customer_app/src/helper/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../controllers/ride_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/helper.dart';
import '../../../helper/styles.dart';
import '../../../models/payment_gateway_enum.dart';
import '../../../models/ride.dart';
import '../../../models/screen_argument.dart';
import '../webview.dart';

class RazorpayPaymentWidget extends StatefulWidget {
  final Ride ride;
  const RazorpayPaymentWidget(this.ride, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RazorpayPaymentWidgetState();
  }
}

class _RazorpayPaymentWidgetState extends StateMVC<RazorpayPaymentWidget> {
  late RideController _con;
  Timer? timer;

  _RazorpayPaymentWidgetState() : super(RideController()) {
    _con = controller as RideController;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void checkPayment() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _con.doCheckPaymentStatus(widget.ride).then((hasChanged) {
        if (hasChanged) {
          timer.cancel();
          Navigator.pushReplacementNamed(
            context,
            '/Ride',
            arguments: ScreenArgument(
              {
                'rideId': widget.ride.id,
              },
            ),
          );
        }
      }).catchError((onError) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _con.loadingPreference
          ? () {}
          : () async {
              checkPayment();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    Helper.getUri('rides/${widget.ride.id}/payWithRazorpay')
                        .toString(),
                    widget.ride.id,
                  ),
                ),
              );
            },
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: Size(MediaQuery.of(context).size.width, 50),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: _con.loadingPreference
          ? CircularProgressIndicator(
              color: Theme.of(context).highlightColor,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.razorpay,
                  height: 50,
                ),
                SizedBox(
                  width: 15,
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.payWith(
                    PaymentGatewayEnumHelper.description(
                      PaymentGatewayEnum.razorpay,
                      context,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: khulaBold.merge(
                    TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
