import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t2p_logistic/domain/enums/add_edit_delivery_boy.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../../domain/Model/user/VerifyOtpResponse.dart';
import '../../../../domain/upload_file_item.dart';
import '../../../constants/view_constants.dart';
import '../../../theme/resource/custom_constants.dart';
import '../../permission_handler.dart';

class AddUser extends StatefulWidget {
  final AddEditDeliveryBoy addEditDeliveryBoy;
  final User? user;

  const AddUser(
      {super.key, required this.addEditDeliveryBoy, this.user});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  AddDeliveryBoyController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  @override
  void initState() {
    var user = widget.user;
    if (user != null) {
      printValue("Edit user ${user}");
      fullNameController.text = user.fullName!;
      emailController.text = user.email!;
      mobileController.text = user.mobile!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        Form(
            key: _formKey,
            child: GetBuilder(
                init: AddDeliveryBoyController(),
                builder: (controller) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(DimensConstants.screePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: fullNameController,
                            decoration:
                                const InputDecoration(label: Text("Full Name")),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter full name";
                              }
                              return null;
                            },
                          ),
                          /*Gap(DimensConstants.spaceBetweenViews),
                        TextFormField(
                          controller: firstNameController,
                          decoration:
                              const InputDecoration(label: Text("Last Name")),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter last name";
                            }
                            return null;
                          },
                        ),*/
                          Gap(DimensConstants.spaceBetweenViews),
                          TextFormField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: const InputDecoration(
                                label: Text("Mobile Number")),
                            validator: (value) {
                              if (value!.isEmpty || value.length < 10) {
                                return "Enter valid mobile number";
                              }
                              return null;
                            },
                          ),
                          Gap(DimensConstants.spaceBetweenViews),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(label: Text("Email")),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter email";
                              }
                              return null;
                            },
                          ),
                          Gap(DimensConstants.spaceBetweenViews),
                          Obx(() => ElevatedButton(
                              onPressed: () async {
                                removeFocus(context);
                                if (controller.isLoading.isFalse &&
                                    _formKey.currentState!.validate()) {
                                  // add boy
                                  if (widget.addEditDeliveryBoy ==
                                      AddEditDeliveryBoy.add) {
                                    await controller.addLogisticBoy(
                                        fullNameController.text,
                                        mobileController.text,
                                        emailController.text);

                                    if (controller.deliveryBoyAdded.isTrue &&
                                        context.mounted) {
                                      resetValue();
                                    }
                                  }
                                  // edit boy
                                  else {
                                    var user = widget.user!;
                                    await controller.editLogisticBoy(
                                        fullNameController.text,
                                        mobileController.text,
                                        emailController.text,
                                        user.address ?? "",
                                        user.city ?? "",
                                        user.serviceZipcode ?? "",
                                        user.id!);
                                  }
                                }
                              },
                              child: controller.isLoading.isTrue
                                  ? circularloadingWhiteSmall()
                                  : Text(widget.addEditDeliveryBoy ==
                                          AddEditDeliveryBoy.edit
                                      ? "Edit"
                                      : "Add"))),
                          Gap(DimensConstants.spaceBetweenViews),
                          const Divider(),
                          Gap(DimensConstants.spaceBetweenViews),

                          // in "add user" case we don't need to show upload documents
                          // todo: upload documents
                          if (widget.addEditDeliveryBoy ==
                              AddEditDeliveryBoy.edit)
                            ListView.separated(
                                itemCount: controller.items.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    height: DimensConstants.spaceBetweenViews,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  return singleUploadItem(
                                      controller.items[index], () async {
                                    showOptions(context, (source) {
                                      pickImage(source, (imagePath, imageName) {
                                        switch (controller.items[index].id) {
                                          case UploadFileItemId.profileImage:
                                            controller.setProfileImages(
                                                imagePath, imageName);
                                            break;
                                          case UploadFileItemId.voterCard:
                                            controller.setVoterImages(
                                                imagePath, imageName);
                                            break;
                                          case UploadFileItemId.panCard:
                                            controller.setPanImages(
                                                imagePath, imageName);
                                            break;
                                          case UploadFileItemId.aadharCard:
                                            controller.setAadharImages(
                                                imagePath, imageName);
                                            break;
                                        }
                                      });
                                    });
                                  });
                                })
                        ],
                      ),
                    ),
                  );
                })));
  }

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

  addBoy() {}

  resetValue() {
    fullNameController.text = "";
    emailController.text = "";
    mobileController.text = "";
  }

  singleUploadItem(UploadFileItem item, Function function) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              function();
            },
            child: (item.id == UploadFileItemId.profileImage &&
                        controller.profileImagePath != null) ||
                    (item.id == UploadFileItemId.voterCard &&
                        controller.voterImagePath != null) ||
                    (item.id == UploadFileItemId.aadharCard &&
                        controller.aadharImagePath != null) ||
                    (item.id == UploadFileItemId.panCard &&
                        controller.panImagePath != null)
                ? Image.file(
                    File(item.id == UploadFileItemId.profileImage
                        ? controller.profileImagePath!
                        : item.id == UploadFileItemId.voterCard
                            ? controller.voterImagePath!
                            : item.id == UploadFileItemId.aadharCard
                                ? controller.aadharImagePath!
                                : controller.panImagePath!),
                    width: double.infinity,
                    height: 100,
                  )
                : Icon(
                    Icons.create_new_folder,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
          Gap(DimensConstants.spaceBetweenViewsAndSubViews),
          Text(
            item.title,
            textAlign: TextAlign.center,
          ),
          Gap(DimensConstants.spaceBetweenViews),
          ElevatedButton(
              onPressed: () async {
                await controller.uploadImage(item.id);
              },
              child: (item.id == UploadFileItemId.profileImage &&
                          controller.profileImageLoading.isTrue) ||
                      (item.id == UploadFileItemId.voterCard &&
                          controller.voterCardLoading.isTrue) ||
                      (item.id == UploadFileItemId.aadharCard &&
                          controller.aadharLoading.isTrue) ||
                      (item.id == UploadFileItemId.panCard &&
                          controller.panLoading.isTrue)
                  ? circularloadingWhiteSmall()
                  : const Text("Upload"))
        ],
      ),
    );
  }
}
