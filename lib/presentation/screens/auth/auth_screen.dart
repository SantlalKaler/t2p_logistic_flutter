import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/auth/widgets/enter_otp.dart';
import 'package:t2p_logistic/presentation/screens/auth/widgets/enter_phone.dart';
import 'package:t2p_logistic/presentation/widgets/app_image.dart';

import '../../theme/resource/image_constants.dart';
import 'auth_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();

    return Scaffold(
        body: Obx(
      () => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              height: 350,
              width: double.infinity,
              child: Center(
                child: getAssetImage(
                  ImageConstants.appLogoCircle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                child: Column(
                  children: [
                    Text(
                      'India\'s Most Trusted Intercity Food Delivery Application',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    authController.isOTPSent.isFalse
                        ? const EnterPhoneWidget()
                        : const EnterOtpWidget()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
