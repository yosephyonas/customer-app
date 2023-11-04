import 'dart:async';
import 'dart:math';

import 'package:driver_customer_app/src/helper/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sign_button/sign_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/user_controller.dart';
import '../../../models/social_network_enum.dart';

class SocialLogin extends StatefulWidget {
  final SocialNetworkEnum socialNetwork;
  const SocialLogin(this.socialNetwork, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SocialLoginState();
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

class _SocialLoginState extends StateMVC<SocialLogin> {
  late UserController _con;
  bool carregouTudo = false;
  String deviceToken = "";
  Random _rnd = Random();
  String securityToken = "";
  Timer? timer;

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  _SocialLoginState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
    this.securityToken = getRandomString(30);
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((String? _deviceToken) {
      this.deviceToken = _deviceToken ?? '';
      setState(() {
        this.carregouTudo = true;
      });
      _launchURL();
    }).catchError((e) {
      setState(() {
        this.carregouTudo = true;
      });
    });

    timer = new Timer.periodic(new Duration(seconds: 5), (timer) async {
      _con.doSocialLogin(securityToken).then((value) async {
        timer.cancel();
        await closeInAppWebView();
        Navigator.of(context).pushReplacementNamed('/Home');
      }).catchError((onError) {});
    });
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!
              .signinWith(widget.socialNetwork.name.capitalize()),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.waitingForLoginInBrowser,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          SignInButton(
            buttonType: widget.socialNetwork == SocialNetworkEnum.facebook
                ? ButtonType.facebook
                : ButtonType.twitter,
            buttonSize: ButtonSize.large,
            btnText: AppLocalizations.of(context)!
                .signinWith(widget.socialNetwork.name.capitalize()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: 10,
            width: MediaQuery.of(context).size.width * 0.8,
            onPressed: () {
              _launchURL();
            },
          ),
        ],
      ),
    );
  }

  void _launchURL() async {
    Uri url = Uri.parse(GlobalConfiguration().getValue("base_url") +
        "login/${widget.socialNetwork.name}?role=driver&mobile=true&deviceToken=" +
        this.deviceToken +
        "&security_token=" +
        this.securityToken);
    await launchUrl(url);
  }
}
