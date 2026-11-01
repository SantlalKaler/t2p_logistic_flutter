import '../../theme/app_design.dart';

import 'package:flutter/material.dart';
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
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      ListView(
        padding: EdgeInsets.all(DimensConstants.screePadding),
        children: [
          AppContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppDesign.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        userController.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppDesign.ink,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(const EditProfileScreen());
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 19,
                      color: AppDesign.muted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(userController.userEmail)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 19,
                      color: AppDesign.muted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(userController.userMobile)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppContainer(
            child: TextButton(
              onPressed: () {
                Get.to(const AddressListScreen());
              },
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your Address',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
