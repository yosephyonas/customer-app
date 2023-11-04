import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/measure_unit_enum.dart';

import '../../models/ride.dart';
import '../../models/payment_gateway_enum.dart';
import '../../models/screen_argument.dart';
import '../../models/status_enum.dart';
import '../../repositories/setting_repository.dart';

class RideItemWidget extends StatefulWidget {
  final bool expanded;
  final Ride ride;
  final Function? loadPedidos;

  RideItemWidget(
      {Key? key, this.expanded = false, this.loadPedidos, required this.ride})
      : super(key: key);

  @override
  _RideItemWidgetState createState() => _RideItemWidgetState();
}

class _RideItemWidgetState extends State<RideItemWidget> {
  late bool expanded;

  @override
  void initState() {
    expanded = widget.expanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: !widget.ride.finalized ? 1 : 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 5,
                    )
                  ],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Card(
                  color: Theme.of(context).highlightColor,
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    onExpansionChanged: (bool _expanded) {
                      setState(() => expanded = _expanded);
                    },
                    initiallyExpanded: expanded,
                    title: Padding(
                      padding:
                          EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy | HH:mm').format(
                                widget.ride.createdAt ?? DateTime.now()),
                            style: khulaBold.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                color: Theme.of(context).primaryColor),
                          ),
                          Expanded(
                            child: Transform.translate(
                              offset: const Offset(25, 0.0),
                              child: AutoSizeText(
                                '${widget.ride.distance.toStringAsFixed(1)}${MeasureUnitEnumHelper.abbreviation(setting.value.measureUnit, context)} - ${NumberFormat.simpleCurrency(name: setting.value.currency).currencySymbol} ${widget.ride.amount.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: khulaBold.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.driver}: ',
                                style: khulaBold.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    color: Theme.of(context).primaryColor),
                              ),
                              Expanded(
                                child: Transform.translate(
                                  offset: const Offset(25, 0.0),
                                  child: AutoSizeText(
                                    '${widget.ride.rideStatus != StatusEnum.pending ? widget.ride.driver?.user?.name : AppLocalizations.of(context)!.searchingDriver}',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    minFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    maxFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    style: khulaBold.copyWith(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (widget.ride.paymentGateway != null ||
                              widget.ride.offlinePaymentMethod != null)
                            Row(
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.paymentMethod}: ',
                                  style: khulaBold.copyWith(
                                      fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                      color: Theme.of(context).primaryColor),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Transform.translate(
                                    offset: const Offset(25, 0.0),
                                    child: AutoSizeText(
                                      widget.ride.paymentGateway != null
                                          ? PaymentGatewayEnumHelper
                                              .description(
                                              widget.ride.paymentGateway!,
                                              context,
                                            )
                                          : widget
                                              .ride.offlinePaymentMethod!.name,
                                      textAlign: TextAlign.right,
                                      minFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                      maxFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                      style: khulaBold.copyWith(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (!expanded)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Transform.translate(
                                  offset: const Offset(40, 0.0),
                                  child: ButtonBar(
                                    buttonPadding: EdgeInsets.zero,
                                    alignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await Navigator.pushNamed(
                                            context,
                                            '/Ride',
                                            arguments: ScreenArgument({
                                              'rideId': widget.ride.id,
                                            }),
                                          ).then((value) {
                                            if (widget.loadPedidos != null) {
                                              widget.loadPedidos!();
                                            }
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .viewCompleteRide,
                                              style: khulaSemiBold.merge(
                                                TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                            ),
                                            Icon(Icons.chevron_right,
                                                size: 25,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                    trailing: SizedBox(),
                    children: <Widget>[
                      if (expanded) SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${AppLocalizations.of(context)!.boardingAddress}:',
                              style: khulaBold.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Expanded(
                              child: Text(
                                (widget.ride.boardingLocation?.name ?? '') +
                                    ' - ' +
                                    (widget.ride.boardingLocation?.number ??
                                        ''),
                                textAlign: TextAlign.right,
                                style: khulaRegular.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${AppLocalizations.of(context)!.rideAddress}:',
                              style: khulaBold.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Expanded(
                              child: Text(
                                widget.ride.destinationLocation!.name,
                                textAlign: TextAlign.right,
                                style: khulaRegular.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ButtonBar(
                        buttonPadding: EdgeInsets.zero,
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/Ride',
                                arguments: ScreenArgument({
                                  'rideId': widget.ride.id,
                                }),
                              ).then((value) {
                                if (widget.loadPedidos != null) {
                                  widget.loadPedidos!();
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .viewCompleteRide,
                                  style: khulaSemiBold.merge(
                                    TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    size: 25,
                                    color: Theme.of(context).primaryColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 28,
          width: 140,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: widget.ride.finalized
                  ? Colors.redAccent
                  : Theme.of(context).primaryColor),
          alignment: AlignmentDirectional.center,
          child: Text(
            StatusEnumHelper.description(widget.ride.rideStatus, context),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.caption!.merge(
                  TextStyle(
                    height: 1,
                    color: Theme.of(context).highlightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
