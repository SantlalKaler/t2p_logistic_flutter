import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Get.back();
        },
        icon: const Icon(Icons.arrow_back_ios));
  }
}
