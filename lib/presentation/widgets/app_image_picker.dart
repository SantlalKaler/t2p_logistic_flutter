
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screens/permission_handler.dart';
import '../theme/resource/custom_constants.dart';
import 'custom_snackbar.dart';

Future pickImage(
    ImageSource source, Function(String name, String path) function,
    {int imageQuality = 40}) async {
  try {
    printValue("image quality is $imageQuality");
    final image = await ImagePicker()
        .pickImage(source: source, imageQuality: imageQuality);
    if (image == null) return;
    final imagePath = File(image.path).path;
    final imageName = imagePath.split('/').last;
    function(imagePath, imageName);
  } on PlatformException catch (e) {
    printValue('Failed to pick image: $e');
  }
}


Future showOptions(BuildContext context, Function function) async {
  showModalBottomSheet(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: const Text(
            "Gallery",
          ),
          onPressed: () {
            Get.back();
            function(ImageSource.gallery);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text(
            "Camera",
          ),
          onPressed: () async {
            Get.back();
            if (await isPermissionGranted(Permission.camera)) {
              function(ImageSource.camera);
            } else {
              if (context.mounted) {
                CustomSnackBar.showSnackBar(
                    CustomSnackBar.error,
                    "Please allow camera permission to capture image.",
                    CustomSnackBar.error);
              }
            }
          },
        ),
      ],
    ),
  );
}
