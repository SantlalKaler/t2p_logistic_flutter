import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/address_list.dart';
import 'package:t2p_logistic/presentation/screens/profile/edit_profile.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';

import '../../widgets/app_container.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
            title: "My Profile",
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        Padding(
          padding: EdgeInsets.all(DimensConstants.screePadding),
          child: Column(
            children: [
              AppContainer(child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userController.userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "\n${userController.userEmail}\n${userController.userMobile}",
                  ),
                  Gap(DimensConstants.spaceBetweenViews),
                  Row(
                    children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              Get.to(const EditProfileScreen());
                            },
                            child: const Text(
                              "Edit",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ))
                    ],
                  )
                ],
              )),
              Gap(DimensConstants.spaceBetweenViews),
              AppContainer(child: TextButton(
                  onPressed: () {
                    Get.to(const AddressListScreen());
                  },
                  child: const Text(
                    "Your Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))),
            ],
          ),
        ));
  }
}
