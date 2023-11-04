import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helper/custom_trace.dart';
import '../models/custom_exception.dart';
import '../models/exceptions_enum.dart';
import '../models/user.dart';
import '../repositories/notification_repository.dart';
import '../repositories/user_repository.dart';
import '../services/user_service.dart';

class UserController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  UserRepository userRepository = UserRepository();
  late User user;

  UserController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> doLoadUser() async {
    await userRepository.getCurrentUser();
  }

  Future<void> doLogin(String email, String password, bool rememberMe) async {
    await login(email, password, rememberMe).then((User user) async {
      await userRepository.setUser(user);
      try {
        await NotificationRepository().updateFcmToken(user);
      } catch (error) {
        print(CustomTrace(StackTrace.current, message: error.toString()));
      }
      ;
    }).catchError((error) async {
      if (error.runtimeType == CustomException &&
          error.exception == ExceptionsEnum.userStatus) {
        await userRepository.setUser(error.data['user']);
        await NotificationRepository().updateFcmToken(error.data['user']);
        throw error;
      } else {
        if (error.message == HttpStatus.unauthorized) {
          throw AppLocalizations.of(scaffoldKey.currentContext!)!
              .incorrectEmailPassword;
        }
        throw AppLocalizations.of(scaffoldKey.currentContext!)!.errorLogin;
      }
    });
  }

  Future<void> doSocialLogin(String securityToken) async {
    await socialLogin(securityToken).then((User user) async {
      await userRepository.setUser(user);
      try {
        await NotificationRepository().updateFcmToken(user);
      } catch (error) {
        print(CustomTrace(StackTrace.current, message: error.toString()));
      }
      ;
    }).catchError((error) async {
      if (error.runtimeType == CustomException &&
          error.exception == ExceptionsEnum.userStatus) {
        await userRepository.setUser(error.data['user']);
        await NotificationRepository().updateFcmToken(error.data['user']);
        throw error;
      } else {
        if (error.message == HttpStatus.unauthorized) {
          throw AppLocalizations.of(scaffoldKey.currentContext!)!
              .incorrectEmailPassword;
        }
        throw AppLocalizations.of(scaffoldKey.currentContext!)!.errorLogin;
      }
    });
  }

  Future<void> doRegister(
      String name, String email, String? phone, String password,
      {String? photo}) async {
    await register(name, email, phone, password, photo: photo)
        .then((User user) async {
      await userRepository.setUser(user);
      try {
        await NotificationRepository().updateFcmToken(user);
      } catch (error) {
        print(CustomTrace(StackTrace.current, message: error.toString()));
      }
      ;
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> doProfileUpdate(String name, String email, String phone,
      {String? password}) async {
    await profileUpdate(name, email, phone, password: password)
        .then((User user) async {
      await userRepository.setUser(user);
      try {
        await NotificationRepository().updateFcmToken(user);
      } catch (error) {
        print(CustomTrace(StackTrace.current, message: error.toString()));
      }
      ;
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> doProfilePictureUpload(File file) async {
    await profilePictureUpload(file).then((User user) async {
      await userRepository.setUser(user);
      setState(() {
        currentUser;
      });
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> doLogout() async {
    user = await userRepository.getCurrentUser();
    if (user.auth) {
      user.firebaseToken = '';
      try {
        await NotificationRepository().updateFcmToken(user);
      } catch (error) {
        print(CustomTrace(StackTrace.current, message: error.toString()));
      }
      ;
    }
    await userRepository.logout();
  }

  Future<void> doForgotPassword(String email) async {
    await forgotPassword(email).then((data) async {
      return true;
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> doVerifyLogin() async {
    await doLoadUser().catchError((error) async {
      await doLogout();
    });
    if (currentUser.value.id.isEmpty) {
      return;
    }
    await verifyLogin(currentUser.value.token).then((User user) async {
      await userRepository.setUser(user);
    }).catchError((error) async {
      if (error.runtimeType == CustomException &&
          error.exception == ExceptionsEnum.userStatus) {
        await userRepository.setUser(error.data['user']);
        throw error;
      } else {
        if (error.message == HttpStatus.unauthorized) {
          await doLogout();
        } else {
          throw AppLocalizations.of(scaffoldKey.currentContext!)!
              .verifyConnection;
        }
      }
    });
  }

  Future<void> doDeleteAccount() async {
    await deleteAccount().catchError((error) {
      throw error;
    });
  }
}
