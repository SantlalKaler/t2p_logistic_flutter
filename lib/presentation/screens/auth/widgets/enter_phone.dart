import 'package:country_flags/country_flags.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/circular_loadings.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/title_divider.dart';
import '../auth_controller.dart';

class EnterPhoneWidget extends StatelessWidget {
  const EnterPhoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();

    return Obx(() => Column(
          children: [
            titleDividerSmall(context, 'Login'),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: authController.phoneTextController.value,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.phone,
              style: Theme.of(context).textTheme.titleSmall,
              maxLength: 10,
              decoration: InputDecoration(
                icon: const Icon(Icons.phone),
                counterText: '',
                hintText: 'Enter 10 digit phone number',
                prefixIcon: const Text('  +91 -  '),
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CountryFlag.fromCountryCode(
                    'IN',
                    height: 20,
                    width: 20,
                    borderRadius: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: authController.isSendingOTP.isTrue
                  ? null
                  : () {
                     // authController.isOTPSent.value = true;
                      if (authController.phoneTextController.value.text == '' ||
                          authController.phoneTextController.value.text.length <
                              10) {
                        CustomSnackBar.showSnackBar(CustomSnackBar.error,
                            'Enter valid phone number', CustomSnackBar.error);
                      } else {
                        authController.sendOtp();
                      }
                    },
              child: authController.isLoading.isTrue
                  ? circularloadingWhiteSmall()
                  : const Text('Get OTP'),
            ),
            const SizedBox(
              height: 3,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(
                      text: 'By continuing you will be agree to our '),
                  TextSpan(
                    recognizer: TapAndPanGestureRecognizer()
                      ..onTapUp = (b) {
                        /*  Get.to(const InfoPolicyScreen(
                            type: DrawerOptions.termsAndConditions));*/
                      },
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    recognizer: TapAndPanGestureRecognizer()
                      ..onTapUp = (b) {
                        /* Get.to(const InfoPolicyScreen(
                            type: DrawerOptions.privacyPolicy));*/
                      },
                    text: 'Privacy policies',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
