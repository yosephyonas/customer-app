import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/measure_unit_enum.dart';
import '../../models/ride.dart';
import '../../models/payment_gateway_enum.dart';
import '../../models/status_enum.dart';
import '../../repositories/setting_repository.dart';

class RideDetailsWidget extends StatefulWidget {
  final Ride ride;

  RideDetailsWidget({
    Key? key,
    required this.ride,
  }) : super(key: key);

  @override
  State<RideDetailsWidget> createState() => _RideDetailsWidgetState();
}

class _RideDetailsWidgetState extends State<RideDetailsWidget> {
  bool transferindoLoading = false;

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        SizedBox(height: 20),
        generateDecoration(
          ListTile(
            title: Text(
              '${AppLocalizations.of(context)!.rideStatus}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).primaryColor),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: AutoSizeText(
                StatusEnumHelper.description(widget.ride.rideStatus, context),
                minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                style: khulaRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        generateDecoration(
          Column(
            children: [
              ListTile(
                title: Text(
                  '${AppLocalizations.of(context)!.totalAmount}:',
                  style: khulaBold.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      color: Color.fromARGB(255, 246, 61, 61)),
                ),
                trailing: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  child: AutoSizeText(
                    '${NumberFormat.simpleCurrency(name: setting.value.currency).currencySymbol} ${widget.ride.amount.toStringAsFixed(2)}',
                    minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                    style: khulaRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 246, 61, 61)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.ride.paymentStatus != null ||
            widget.ride.paymentGateway != null ||
            widget.ride.offlinePaymentMethod != null)
          generateDecoration(
            Column(
              children: [
                if (widget.ride.paymentGateway != null ||
                    widget.ride.offlinePaymentMethod != null)
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context)!.paymentMethod}:',
                      style: khulaBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).primaryColor),
                    ),
                    trailing: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: AutoSizeText(
                        widget.ride.paymentGateway != null
                            ? PaymentGatewayEnumHelper.description(
                                widget.ride.paymentGateway!,
                                context,
                              )
                            : widget.ride.offlinePaymentMethod!.name,
                        minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                        style: khulaRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                if (widget.ride.paymentStatus != null)
                  ListTile(
                    title: Text(
                      '${AppLocalizations.of(context)!.paymentStatus}:',
                      style: khulaBold.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).primaryColor),
                    ),
                    trailing: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                      child: AutoSizeText(
                        StatusEnumHelper.description(
                            widget.ride.paymentStatus!, context),
                        minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                        style: khulaRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        generateDecoration(
          ListTile(
            title: Text(
              '${AppLocalizations.of(context)!.estimatedDistance}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).primaryColor),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: AutoSizeText(
                '${widget.ride.distance.toStringAsFixed(1)} ${MeasureUnitEnumHelper.abbreviation(setting.value.measureUnit, context)}',
                minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                style: khulaRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        generateDecoration(
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
              vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
            ),
            title: Text(
              '${AppLocalizations.of(context)!.driver}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: Theme.of(context).primaryColor),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.ride.rideStatus != StatusEnum.pending)
                    AutoSizeText(
                      widget.ride.driver!.user!.name,
                      minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: khulaRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  SizedBox(height: 5),
                  if (widget.ride.rideStatus != StatusEnum.pending)
                    AutoSizeText(
                      widget.ride.driver!.user!.phone,
                      minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: khulaRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  else
                    AutoSizeText(
                      AppLocalizations.of(context)!.searchingDriver,
                      minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: khulaRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.ride.observation != null)
          generateDecoration(
            ListTile(
              title: Text(
                '${AppLocalizations.of(context)!.note}:',
                style: khulaBold.copyWith(
                    fontSize: Dimensions.FONT_SIZE_LARGE,
                    color: Theme.of(context).primaryColor),
              ),
              trailing: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: AutoSizeText(
                  widget.ride.observation!,
                  minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                  style: khulaRegular.copyWith(
                    fontSize: Dimensions.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
