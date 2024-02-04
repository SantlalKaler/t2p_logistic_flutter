import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/splash/setting_controller.dart';

import '../../theme/resource/image_constants.dart';
import '../../widgets/app_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    SettingsController redirectionsController = Get.find();
    redirectionsController.moveToNext();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: getAssetImageProvider(ImageConstants.splashScreen),
                  fit: BoxFit.cover))),
    );
  }
}
