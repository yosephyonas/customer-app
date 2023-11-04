import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../controllers/user_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/assets.dart';
import '../../helper/styles.dart';
import '../../repositories/user_repository.dart';
import 'sign_out_confirmation_dialog.dart';

// ignore: must_be_immutable
class MenuWidget extends StatefulWidget {
  Function? onSwitchTab;
  MenuWidget({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MenuWidgetState();
  }
}

class MenuWidgetState extends StateMVC<MenuWidget> {
  late UserController _userCon;

  MenuWidgetState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          InkWell(
            onTap: !currentUser.value.auth
                ? () {}
                : () {
                    Navigator.of(context).pushReplacementNamed(
                      '/Profile',
                    );
                  },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 40, bottom: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xFFD1D5DA), width: 2)),
                      child: ClipOval(
                          child: currentUser.value.picture != null &&
                                  currentUser.value.picture!.id != ''
                              ? CachedNetworkImage(
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Center(
                                    child: CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                                  ),
                                  imageUrl: currentUser.value.picture!.url,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(Assets.placeholderUser,
                                  color: Theme.of(context).primaryColor,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.scaleDown)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.PADDING_SIZE_SMALL),
                      child: Text(
                        currentUser.value.name,
                        style: TextStyle(
                            fontSize: Dimensions.FONT_SIZE_LARGE,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ]),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                Divider(
                    color: Theme.of(context).colorScheme.secondary, height: 0),
                ListTile(
                  horizontalTitleGap: 0,
                  onTap: () async {
                    if (widget.onSwitchTab != null) {
                      widget.onSwitchTab!('Home');
                    } else {
                      Navigator.of(context).pushReplacementNamed('/Home');
                    }
                  },
                  leading: Icon(FontAwesomeIcons.house,
                      color: Theme.of(context).primaryColor),
                  title: Text(
                    AppLocalizations.of(context)!.home,
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                if (currentUser.value.auth)
                  Column(
                    children: [
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!('RecentRides');
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed('/RecentRides');
                          }
                        },
                        leading: Icon(FontAwesomeIcons.carSide,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.recentRides,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!('Profile');
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed('/Profile');
                          }
                        },
                        leading: Icon(FontAwesomeIcons.userPen,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.profile,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => SignOutConfirmationDialog(
                                      onConfirmed: () async {
                                    await _userCon.doLogout();
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/Login', (route) => false);
                                    setState(() {});
                                  }));
                        },
                        leading: Icon(Icons.logout,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.logout,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!('Login');
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed('/Login');
                          }
                        },
                        leading: Icon(Icons.login,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.login,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
