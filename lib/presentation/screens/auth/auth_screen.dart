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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Obx(
              () => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: Center(
                        child: getAssetImage(
                          ImageConstants.appLogoCircle,
                          height: 150,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: Form(
                        child: Column(
                          children: [
                            Text(
                              'India\'s Most Trusted Intercity Food Delivery Application',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            authController.isOTPSent.isFalse
                                ? const EnterPhoneWidget()
                                : const EnterOtpWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
