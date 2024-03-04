import 'package:mstoo/user/components/footer_base_view.dart';
import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:mstoo/user/components/web_shadow_wrap.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
// import 'package:telephony/telephony.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:otp_autofill/otp_autofill.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final bool fromVerification;
  final String identityType;
  const VerificationScreen(
      {super.key,
      this.identity,
      required this.fromVerification,
      required this.identityType});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _identity;
  Timer? _timer;
  int? _seconds = 0;
  bool otpSent = false;
  bool isVerifyingOTP = false;

  String otp = '';
  // Telephony telephony = Telephony.instance;
  OtpFieldController otpbox = OtpFieldController();
  late OTPTextEditController controller;
  late OTPInteractor _otpInteractor;
  String codeValue = "";

  @override
  void initState() {
    super.initState();
    if ((widget.fromVerification &&
            Get.find<SplashController>()
                    .configModel
                    .content
                    ?.phoneVerification ==
                1) ||
        (!widget.fromVerification &&
            Get.find<SplashController>()
                    .configModel
                    .content
                    ?.forgetPasswordVerificationMethod ==
                "phone")) {
      _identity = widget.identity!.startsWith('+')
          ? widget.identity
          : '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else {
      _identity = widget.identity;
    }

    _startTimer();
    listenOtp();

    // telephony.listenIncomingSms(
    //   onNewMessage: (SmsMessage message) {
    //     print(message.address);
    //     print(message.body);

    //   String sms = message.body.toString();

    //   if (message.body!.contains('onetext')) {
    //     String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
    //     otpbox.set(otpcode.split(""));

    //     setState(() {
    //       // refresh UI
    //     });
    //   } else {
    //     print("error");
    //   }
    // },
    //   listenInBackground: false,
    // );
  }

  void listenOtp() async {
    await SmsAutoFill().unregisterListener();
    await SmsAutoFill().listenForCode;

    print("OTP listen Called");
  }

  void _startTimer() {
    _seconds =
        Get.find<SplashController>().configModel.content?.resentOtpTime ?? 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    print("unregisterListener");
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer:
          ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
      appBar: CustomAppBar(title: 'otp_verification'.tr),
      body: SafeArea(
          child: FooterBaseView(
        isCenter: true,
        child: WebShadowWrap(
          child: Scrollbar(
              child: SizedBox(
            height: MediaQuery.of(context).size.height - 130,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge),
                child: GetBuilder<AuthController>(builder: (authController) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.webMaxWidth / 6
                            : ResponsiveHelper.isTab(context)
                                ? Dimensions.webMaxWidth / 8
                                : 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Images.logo,
                          width: Dimensions.logoSize,
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraMoreLarge,
                        ),
                        Column(
                          children: [
                            Text('enter_the_verification'.tr,
                                style: ubuntuRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(0.5))),
                            const SizedBox(
                              height: Dimensions.paddingSizeSmall,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('sent_to'.tr,
                                    style: ubuntuRegular.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withOpacity(0.5))),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),
                                Text('$_identity',
                                    style: ubuntuMedium.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),
                        SizedBox(
                          width: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.webMaxWidth / 2.5
                              : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 3
                                  : Dimensions.webMaxWidth / 4,
                          child: PinFieldAutoFill(
                            currentCode: codeValue,
                            codeLength: 4,
                            onCodeChanged: (code) {
                              
                              print("onCodeChanged $code");
                              setState(() {
                                codeValue = code.toString();
                                authController.updateVerificationCode(codeValue);
                              });
                            },
                            onCodeSubmitted: (val) {
                              print("onCodeSubmitted $val");
                            },
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeLarge,
                        ),
                        authController.verificationCode.length == 4
                            ? !authController.isLoading!
                                ? SizedBox(
                                    width: 300, //width of button
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 3, //elevation of button
                                            shape: RoundedRectangleBorder(
                                                //to set border radius to button
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            padding: EdgeInsets.all(
                                                20) //content padding inside button
                                            ),
                                        onPressed: () {
                                          authController.verifyLogin(
                                              _identity!,
                                              widget.identityType,
                                              authController.verificationCode);
                                        },
                                        child: Text("Verify")))
                                : const Center(
                                    child: CircularProgressIndicator())
                            : 
                         const SizedBox.shrink(),
                        (widget.identity != null && widget.identity!.isNotEmpty)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Text(
                                      'did_not_receive_the_code'.tr,
                                      style: ubuntuRegular.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withOpacity(0.5)),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          minimumSize: const Size(1, 40),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      onPressed: _seconds! < 1
                                          ? () {
                                              if (widget.fromVerification)  {
                                                authController
                                                    .sendOtpForVerificationScreen(
                                                        _identity!,
                                                        widget.identityType)
                                                    .then((value) {
                                                  if (value.isSuccess!)  {
                                                    // listenOtp();
                                                    SmsAutoFill().listenForCode();
                                                    _startTimer();
                                                    customSnackBar(
                                                        'resend_code_successful'
                                                            .tr,
                                                        isError: false);
                                                  } else {
                                                    customSnackBar(
                                                        value.message);
                                                  }
                                                });
                                              } else {
                                                authController
                                                    .sendOtpForForgetPassword(
                                                        _identity!,
                                                        widget.identityType)
                                                    .then((value) {
                                                  if (value.isSuccess!) {
                                                    _startTimer();
                                                    customSnackBar(
                                                        'resend_code_successful'
                                                            .tr,
                                                        isError: false);
                                                  } else {
                                                    customSnackBar(
                                                        value.message);
                                                  }
                                                });
                                              }
                                            }
                                          : null,
                                      child: Text(
                                          '${'resend'.tr}${_seconds! > 0 ? ' ($_seconds)' : ''}',
                                          style: ubuntuRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                    ),
                                  ])
                            : const SizedBox(),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraMoreLarge,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          )),
        ),
      )),
    );
  }

  void _otpVerify(String identity, String identityType, String otp,
      AuthController authController) async {
    if (widget.fromVerification) {
      authController
          .verifyOtpForVerificationScreen(identity, identityType, otp)
          .then((status) {
        if (status.isSuccess!) {
          customSnackBar(status.message, isError: false);
          Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
        } else {
          customSnackBar(status.message.toString().capitalizeFirst);
        }
      });
    } else {
      authController
          .verifyOtpForForgetPasswordScreen(identity, identityType, otp)
          .then((status) async {
        if (status.isSuccess!) {
          Get.offNamed(
              RouteHelper.getChangePasswordRoute(identity, identityType, otp));
        } else {
          customSnackBar(status.message.toString().capitalizeFirst);
        }
      });
    }
  }
}
