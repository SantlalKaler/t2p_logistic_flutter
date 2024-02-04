import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';

import '../../widgets/app_container.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  UserController userController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  @override
  void initState() {
    nameController.text = userController.userName;
    emailController.text = userController.userEmail;
    mobileController.text = userController.userMobile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
            title: "Edit Profile",
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        Padding(
          padding: EdgeInsets.all(DimensConstants.screePadding),
          child: Column(
            children: [
              appContainer(Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(label: Text("Full Name")),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter first name";
                          }
                          return null;
                        },
                      ),
                      Gap(DimensConstants.spaceBetweenViews),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(label: Text("Email")),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter email";
                          }
                          return null;
                        },
                      ),
                      Gap(DimensConstants.spaceBetweenViews),
                      TextFormField(
                        controller: mobileController,
                        decoration:
                            const InputDecoration(label: Text("Mobile")),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter mobile";
                          }
                          return null;
                        },
                      ),
                      Gap(DimensConstants.highSpacing),

                      ElevatedButton(onPressed: () {
                        Get.back();
                      }, child: const Text("Save Details"))
                    ],
                  ))),
            ],
          ),
        ));
  }
}
