import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/DeliveryBoyController.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../../../domain/Model/user/VerifyOtpResponse.dart';
import '../../../../domain/Model/user/user.dart';
import '../../../../domain/enums/add_edit_delivery_boy.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/app_empty_view.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_text.dart';

class ManageDeliveryBoy extends StatefulWidget {
  const ManageDeliveryBoy({super.key});

  @override
  State<ManageDeliveryBoy> createState() => _ManageDeliveryBoyState();
}

class _ManageDeliveryBoyState extends State<ManageDeliveryBoy> {
  DeliveryBoyController deliveryBoyController = Get.find();

  @override
  void initState() {
    deliveryBoyController.getListLogisticBoy();
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
        Padding(
          padding: EdgeInsets.all(DimensConstants.screePadding),
          child: GetBuilder(
              init: DeliveryBoyController(),
              builder: (controller) {
                return controller.isLoading.isTrue
                    ? Center(child: circularloadingRedSmall())
                    : controller.boyList.isEmpty
                        ? const AppEmptyView(
                            message: "No User Found.",
                          )
                        : ListView.separated(
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Get.to(() => AddUser(
                                      addEditDeliveryBoy:
                                          AddEditDeliveryBoy.edit,
                                      user: controller.boyList[index]));
                                },
                                child: singleUserItem(controller.boyList[index],
                                    onStatusChange: (userId) {
                                  controller.userStatusChange(userId);
                                }),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: DimensConstants.spaceBetweenViews,
                              );
                            },
                            itemCount: controller.boyList.length);
              }),
        ));
  }
}

singleUserItem(User user,
    {Function? onStatusChange, bool showSwitchButton = true}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), color: Colors.white),
    padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //getNetworkImage(user.profileImage.toString(), height: 70, width: 70),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeading2Text(
              text: user.fullName ?? "",
            ),
            AppNormalText(
              text: "\n${user.mobile}",
            ),
          ],
        ),

        if (showSwitchButton)
          Switch(
              value: user.active == 1,
              onChanged: (value) {
                onStatusChange!(user.id);
              })
      ],
    ),
  );
}
