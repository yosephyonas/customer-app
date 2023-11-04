import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../helper/helper.dart';
import '../../repositories/setting_repository.dart';

class LegalTermsWidget extends StatefulWidget {
  @override
  _LegalTermsWidgetState createState() => _LegalTermsWidgetState();
}

class _LegalTermsWidgetState extends State<LegalTermsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.headline6!.color,
        ),
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.termsUse,
          style: Theme.of(context)
              .textTheme
              .headline6!
              .merge(TextStyle(letterSpacing: 1.3)),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 20, 12),
              child: Helper.applyHtml(context, setting.value.termsOfService),
            ),
          ],
        ),
      ),
    );
  }
}
