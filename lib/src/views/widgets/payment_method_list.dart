import 'package:driver_customer_app/src/helper/dimensions.dart';
import 'package:driver_customer_app/src/helper/assets.dart';
import 'package:driver_customer_app/src/models/payment_gateway_enum.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/styles.dart';
import '../../models/selected_payment_method.dart';
import '../../repositories/setting_repository.dart';

class PaymentMethodListWidget extends StatelessWidget {
  final SelectedPaymentMethod? selectedPaymentMethod;
  final Function? onSelectedPaymentChanged;
  const PaymentMethodListWidget(
      this.selectedPaymentMethod, this.onSelectedPaymentChanged,
      {Key? key})
      : super(key: key);

  Widget buildPaymentTile(
      context, Widget icon, SelectedPaymentMethod paymentMethod) {
    bool isSelected = selectedPaymentMethod?.id == paymentMethod.id;
    return InkWell(
      onTap: () {
        if (onSelectedPaymentChanged != null) {
          onSelectedPaymentChanged!(paymentMethod);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 9, top: 6, bottom: 7, right: 10),
        height: 55,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
              child: icon,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                paymentMethod.name,
                style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  color: isSelected
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Align(
          child: Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.PADDING_SIZE_DEFAULT,
              bottom: Dimensions.PADDING_SIZE_DEFAULT,
            ),
            child: Text(
              AppLocalizations.of(context)!.selectPaymentMethod,
              style: kSubtitleStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        for (var paymentMethod in setting.value.offlinePaymentMethods)
          buildPaymentTile(
            context,
            paymentMethod.picture!.id.isEmpty
                ? Icon(FontAwesomeIcons.dollarSign, color: Colors.green[800])
                : Image.network(
                    paymentMethod.picture!.url,
                  ),
            SelectedPaymentMethod(PaymentTypeEnum.offline,
                id: paymentMethod.id,
                name: paymentMethod.name,
                offlinePaymentMethod: paymentMethod),
          ),
        if (setting.value.stripeEnabled)
          buildPaymentTile(
            context,
            Icon(
              FontAwesomeIcons.ccStripe,
              color: selectedPaymentMethod?.id == PaymentGatewayEnum.stripe.name
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            SelectedPaymentMethod(PaymentTypeEnum.online,
                id: PaymentGatewayEnum.stripe.name,
                name: PaymentGatewayEnumHelper.description(
                    PaymentGatewayEnum.stripe, context)),
          ),
        if (setting.value.mercadoPagoEnabled)
          buildPaymentTile(
            context,
            Image.asset(
              Assets.mercadoPago,
            ),
            SelectedPaymentMethod(PaymentTypeEnum.online,
                id: PaymentGatewayEnum.mercado_pago.name,
                name: PaymentGatewayEnumHelper.description(
                    PaymentGatewayEnum.mercado_pago, context)),
          ),
        if (setting.value.paypalEnabled)
          buildPaymentTile(
            context,
            Icon(
              FontAwesomeIcons.ccPaypal,
              color: selectedPaymentMethod?.id == PaymentGatewayEnum.paypal.name
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            SelectedPaymentMethod(PaymentTypeEnum.online,
                id: PaymentGatewayEnum.paypal.name,
                name: PaymentGatewayEnumHelper.description(
                    PaymentGatewayEnum.paypal, context)),
          ),
        if (setting.value.flutterwaveEnabled)
          buildPaymentTile(
            context,
            Image.asset(
              Assets.flutterwave,
            ),
            SelectedPaymentMethod(
              PaymentTypeEnum.online,
              id: PaymentGatewayEnum.flutterwave.name,
              name: PaymentGatewayEnumHelper.description(
                  PaymentGatewayEnum.flutterwave, context),
            ),
          ),
        if (setting.value.razorpayEnabled)
          buildPaymentTile(
            context,
            Image.asset(
              Assets.razorpay,
            ),
            SelectedPaymentMethod(
              PaymentTypeEnum.online,
              id: PaymentGatewayEnum.razorpay.name,
              name: PaymentGatewayEnumHelper.description(
                  PaymentGatewayEnum.razorpay, context),
            ),
          ),
      ],
    );
  }
}
