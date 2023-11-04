import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/user_controller.dart';
import '../../helper/assets.dart';
import '../../helper/styles.dart';
import '../../repositories/user_repository.dart';

class ProfileImageEdit extends StatefulWidget {
  const ProfileImageEdit({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileImageEditState();
  }
}

class _ProfileImageEditState extends StateMVC<ProfileImageEdit> {
  late UserController _userCon;
  bool loadingImage = false;
  final ImagePicker _picker = ImagePicker();
  String imageUrl = currentUser.value.picture?.url ?? '';

  _ProfileImageEditState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  void _onImageButtonPressed(ImageSource source) async {
    if (!await checkCameraPermission(source)) {
      return;
    }
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File _image = File(pickedFile.path);
      setState(() {
        this.loadingImage = true;
      });
      await _userCon.doProfilePictureUpload(_image).then((value) {
        setState(() {
          this.loadingImage = false;
        });
      }).catchError((error) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.thereWasErrorSendingImage);
        setState(() {
          this.loadingImage = false;
        });
      });
      setState(() {
        imageUrl = currentUser.value.picture!.url;
      });
    }
  }

  Future<bool> checkCameraPermission(ImageSource source) async {
    try {
      var status = source == ImageSource.camera
          ? await Permission.camera.status
          : (Platform.isIOS
              ? await Permission.photos.status
              : await Permission.storage.status);
      if (!status.isGranted) {
        var permissionStatus = source == ImageSource.camera
            ? await Permission.camera.request()
            : (Platform.isIOS
                ? await Permission.photos.request()
                : await Permission.storage.request());
        if (permissionStatus.isGranted) {
          return true;
        }
        await showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(source == ImageSource.camera
                ? AppLocalizations.of(context)!.cameraAccess
                : AppLocalizations.of(context)!.galleryAccess),
            content: Text(AppLocalizations.of(context)!.allowAppAccessThe(
                source == ImageSource.camera
                    ? AppLocalizations.of(context)!.camera
                    : AppLocalizations.of(context)!.gallery)),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.goToSettings),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFD1D5DA), width: 2)),
          child: (loadingImage)
              ? TextButton(
                  onPressed: () => {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  child: CircularProgressIndicator(color: Colors.black))
              : ClipOval(
                  child: imageUrl != ''
                      ? CachedNetworkImage(
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          ),
                          imageUrl: imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          Assets.placeholderUser,
                          color: Theme.of(context).primaryColor,
                          height: 100,
                          width: 100,
                          fit: BoxFit.scaleDown,
                        ),
                ),
        ),
        SizedBox(
          height: 15,
        ),
        if (!loadingImage)
          PopupMenuButton(
            padding: EdgeInsets.all(0),
            onSelected: (val) {
              _onImageButtonPressed((val as ImageSource));
            },
            child: Text(
              AppLocalizations.of(context)!.updatePhoto,
              textAlign: TextAlign.center,
              style: poppinsSemiBold.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.photo_camera,
                        color: Theme.of(context).hintColor),
                    SizedBox(width: 5),
                    Text(AppLocalizations.of(context)!.camera),
                  ],
                ),
                value: ImageSource.camera,
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: Theme.of(context).hintColor,
                    ),
                    SizedBox(width: 5),
                    Text(AppLocalizations.of(context)!.gallery),
                  ],
                ),
                value: ImageSource.gallery,
              ),
            ],
          ),
      ],
    );
  }
}
