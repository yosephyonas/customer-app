import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:validators/validators.dart';

import '../../../controllers/user_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/styles.dart';
import '../../../repositories/setting_repository.dart';
import '../../widgets/custom_text_form_field.dart';
import '../legal_terms.dart';
import '../privacy_policy.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignupScreenState();
  }
}

class SignupScreenState extends StateMVC<SignupScreen> {
  late UserController _userCon;
  TextEditingController passwordController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String phone = "";
  String name = "";
  String email = "";
  String password = "";

  String phoneError = "";
  String nameError = "";
  String emailError = "";
  String passwordError = "";

  SignupScreenState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  void clearError() {
    setState(() {
      phoneError = "";
      nameError = "";
      emailError = "";
      passwordError = "";
    });
  }

  Future<void> showQuitRegisterDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.wantToLeaveRegistration),
        content:
            Text(AppLocalizations.of(context)!.exitingRegistrationDataLost),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.leave),
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          AppLocalizations.of(context)!.registration,
          style: khulaSemiBold.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () async {
            await showQuitRegisterDialog();
          },
        ),
        elevation: 1,
        shadowColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Text(
                      AppLocalizations.of(context)!.letsStartWithLogin,
                      style: kTitleStyle.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.PADDING_SIZE_EXTRA_LARGE,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                        errorText: nameError,
                        isRequired: true,
                        validator: (String value) {
                          if (value.isEmpty || value.length <= 3) {
                            return AppLocalizations.of(context)!.enterFullName;
                          }
                          return null;
                        },
                        onSave: (String value) {
                          setState(() => name = value);
                        },
                        hintText: AppLocalizations.of(context)!.fullName,
                        labelText: AppLocalizations.of(context)!.fullName,
                        focusNode: _fullNameFocus,
                        nextFocus: _emailFocus,
                        inputType: TextInputType.name,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(150)
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                        errorText: emailError,
                        isRequired: true,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)!.enterEmail;
                          } else if (!isEmail(value)) {
                            return AppLocalizations.of(context)!
                                .enterValidEmail;
                          }
                          return null;
                        },
                        onSave: (String value) {
                          setState(() => email = value);
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(191)
                        ],
                        hintText: AppLocalizations.of(context)!.email,
                        labelText: AppLocalizations.of(context)!.email,
                        focusNode: _emailFocus,
                        nextFocus: _phoneFocus,
                        inputType: TextInputType.emailAddress,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                        errorText: phoneError,
                        isRequired: true,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .enterPhoneCorrectly;
                          } else if (value.length < 8) {
                            return AppLocalizations.of(context)!
                                .enterFullPhoneNumber;
                          }
                          return null;
                        },
                        onSave: (String value) {
                          setState(() => phone = value);
                        },
                        hintText: AppLocalizations.of(context)!.phone,
                        labelText: AppLocalizations.of(context)!.phone,
                        focusNode: _phoneFocus,
                        nextFocus: _passwordFocus,
                        inputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                        errorText: passwordError,
                        controller: passwordController,
                        isRequired: true,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)!.enterPassword;
                          } else if (value.length < 6) {
                            return AppLocalizations.of(context)!
                                .inputMinimumSize(
                                    AppLocalizations.of(context)!.thePassword,
                                    6);
                          }
                          return null;
                        },
                        onSave: (String value) {
                          setState(() => password = value);
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(80)],
                        hintText: AppLocalizations.of(context)!.password,
                        labelText: AppLocalizations.of(context)!.password,
                        isPassword: true,
                        focusNode: _passwordFocus,
                        nextFocus: _confirmPasswordFocus,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                        errorText: passwordError,
                        isRequired: true,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .enterPasswordConfirmation;
                          } else if (value.length < 6) {
                            return AppLocalizations.of(context)!
                                .inputMinimumSize(
                                    AppLocalizations.of(context)!.thePassword,
                                    6);
                          } else if (value != passwordController.text) {
                            return AppLocalizations.of(context)!
                                .passwordsNotMatch;
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(191)
                        ],
                        onSave: (String value) {},
                        hintText: AppLocalizations.of(context)!.confirmPassword,
                        labelText:
                            AppLocalizations.of(context)!.confirmPassword,
                        isPassword: true,
                        focusNode: _confirmPasswordFocus,
                        inputAction: TextInputAction.done,
                      ),
                    ),
                    if (setting.value.enableTermsOfService ||
                        setting.value.enablePrivacyPolicy)
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                        child: Text.rich(
                          TextSpan(
                            text:
                                '${AppLocalizations.of(context)!.declareHaveReadAgreed} ',
                            style: poppinsRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL,
                                color: Color.fromARGB(255, 76, 76, 76)),
                            children: <TextSpan>[
                              if (setting.value.enableTermsOfService)
                                TextSpan(
                                  text: AppLocalizations.of(context)!.termsUse,
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () => Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                LegalTermsWidget(),
                                          ),
                                        ),
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    color: Color.fromARGB(255, 76, 76, 76),
                                  ),
                                ),
                              if (setting.value.enableTermsOfService &&
                                  setting.value.enablePrivacyPolicy)
                                TextSpan(
                                  text:
                                      ' ${AppLocalizations.of(context)!.and} ',
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                    color: Color.fromARGB(255, 76, 76, 76),
                                  ),
                                ),
                              if (setting.value.enablePrivacyPolicy)
                                TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .privacyPolicy,
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () => Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                PrivacyPolicyWidget(),
                                          ),
                                        ),
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    color: Color.fromARGB(255, 76, 76, 76),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      height: 45,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 1)),
                        ],
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        onPressed: loading
                            ? () {}
                            : () async {
                                clearError();
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  setState(() => loading = true);
                                  await _userCon
                                      .doRegister(name, email, phone, password)
                                      .then((value) {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        "/Home",
                                        (Route<dynamic> route) => false);
                                  }).catchError((error) {
                                    setState(() => loading = false);
                                    if (error.message is Map) {
                                      error.message.forEach((index, value) {
                                        switch (index) {
                                          case "name":
                                            setState(
                                                () => nameError = value[0]);
                                            break;
                                          case "email":
                                            setState(
                                                () => emailError = value[0]);
                                            break;
                                          case "phone":
                                            setState(
                                                () => phoneError = value[0]);
                                            break;
                                          case "password":
                                            setState(
                                                () => passwordError = value[0]);
                                            break;
                                          default:
                                            break;
                                        }
                                      });
                                    }
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .errorRegister),
                                      backgroundColor:
                                          Theme.of(context).errorColor,
                                    ));
                                  });
                                  setState(() => loading = false);
                                  return;
                                }
                              },
                        child: loading
                            ? CircularProgressIndicator(
                                color: Theme.of(context).highlightColor)
                            : Text(
                                AppLocalizations.of(context)!.register,
                                style: poppinsSemiBold.copyWith(
                                    color: Theme.of(context).highlightColor),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: loading
                    ? () {}
                    : () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/Login', (Route<dynamic> route) => false);
                      },
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.haveAnAccount,
                        style: poppinsRegular.copyWith(
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AppLocalizations.of(context)!.signIn,
                        style: poppinsRegular.copyWith(
                          color: Colors.lightBlue,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
