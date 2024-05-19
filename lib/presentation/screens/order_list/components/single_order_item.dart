import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/components/single_order_info_item.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/enums/other.dart';
import '../../../../domain/mapper/order_mapper.dart';
import '../../../dialogs/af2ap_product_dialog.dart';
import '../../../dialogs/default_dialog.dart';
import '../../../theme/resource/dimens.dart';
import '../../../widgets/app_container.dart';
import '../../../widgets/circular_loadings.dart';

class SingleOrderItem extends StatelessWidget {
  final CommonOrder order;

  const SingleOrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    OrderController controller = Get.find();
    UserController userController = Get.find();
    return AppContainer(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100), color: Colors.red),
              child: Text(
                order.paymentMode!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Text(
              "Order No : ${order.orderId}\n${order.createdAt}",
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleOrderInfoItem(
                  title: order.pickupCity!,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: verticalDivider(),
                ),
                SingleOrderInfoItem(
                  title: order.deliveryCity!,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (controller.t2pOrderType == T2POrderType.AF2AP)
                  Text(
                    "Due : Rs. ${order.duesAmount}\nPaid : Rs. ${order.paidAmount}\n",
                    textAlign: TextAlign.end,
                  ),
                Text("Rs. ${order.price}"),
                Gap(DimensConstants.spaceBetweenViews),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green.shade50),
                  child: Text(
                    controller.orderType == OrderType.pickup
                        ? order.pickupBoy!
                        : order.deliveryBoy!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            )
          ],
        ),
        Gap(DimensConstants.highSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleOrderInfoItem(
                title:
                    "Pickup Weight : ${order.pickupWeight?.toFixString()} KG",
                height: 5,
                width: 5,
                color: Colors.red),
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        SingleOrderInfoItem(
            title: "Delivery Weight : ${order.deliveryWeight.toFixString()} KG",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        const SingleOrderInfoItem(
            title: "Product : ", height: 5, width: 5, color: Colors.red),
        Text(order.productNames!),
        Gap(DimensConstants.spaceBetweenViews),
        SingleOrderInfoItem(
            title: "Express : ${order.express}",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        InkWell(
          onTap: () async {
            launchDialer(order.customerNumber!);
          },
          child: SingleOrderInfoItem(
              title: "Customer Mobile : ${order.customerNumber}",
              height: 5,
              width: 5,
              color: Colors.red),
        ),
        Gap(DimensConstants.spaceBetweenViews),
        const SingleOrderInfoItem(
            title: "Customer Address : ",
            height: 5,
            width: 5,
            color: Colors.red),
        Text(
          "${controller.t2pOrderType == T2POrderType.T2P
              ? order.customerAddress
              : controller.orderType == OrderType.pickup
              ? "${order.pickupAddress?.contactName}, \n${order.pickupAddress?.address}, \n${order.pickupAddress?.city?.name}, ${order.pickupAddress?.state?.name}\n${order.pickupAddress?.pincode}"
              : "${order.deliveryAddress?.contactName}, \n${order.deliveryAddress?.address}, \n${order.deliveryAddress?.city?.name}, ${order.deliveryAddress?.state?.name}\n${order.deliveryAddress?.pincode}"}",
          maxLines: 20,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        /*Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Payment Mode : ", height: 5, width: 5, color: Colors.red),*/
        Gap(DimensConstants.spaceBetweenViews),
        if (order.pickupDate?.isNotEmpty == true)
          SingleOrderInfoItem(
              title: "Pickup Date : ${order.pickupDate}",
              height: 5,
              width: 5,
              color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        if (order.pickupTime?.isNotEmpty == true)
          SingleOrderInfoItem(
              title: "Pickup Time : ${order.pickupTime}",
              height: 5,
              width: 5,
              color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        SingleOrderInfoItem(
            title: "Delivery Date : ${order.deliveryDate}",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        SingleOrderInfoItem(
            title: "Delivery Time : ${order.deliveryTime}",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        SingleOrderInfoItem(
            title: "Status : ${order.orderStatus}",
            height: 5,
            width: 5,
            color: Colors.red),
        //Gap(DimensConstants.spaceBetweenViews),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                tileColor: Theme.of(context).primaryColor,
                checkColor: Colors.green,
                value: controller.orderSelected(order.id!),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectOrder(order.id!);
                  }
                },
                title: const Text(
                  "Select Order",
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            /** who can update t2p order weight
                1. partner, of pickup orders
                2. boy, of delivery orders
                <----------------------------->
                who can update af2ap order weight, height, width, length
                1. only pickup boy **/

            if (userController.userType == UserType.delivery_boy.name &&
                controller.orderType == OrderType.pickup)
              Expanded(
                  child: controller.updateButtonLoading.isTrue
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [circularloadingRedSmall()],
                        )
                      : TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return controller.t2pOrderType ==
                                        T2POrderType.T2P
                                    ? t2pWeightUpdateDialog(order.id!)
                                    : AF2APProductDialog(
                                        order: order,
                                      );
                              },
                            );
                          },
                          child: const Text("Update"))),

            // if af2ap pickup boy take payment when he pick food from user
            /*if (userController.userType == UserType.delivery_boy.name &&
                controller.orderType == OrderType.pickup && controller.t2pOrderType == T2POrderType.AF2AP)
              Expanded(
                  child:TextButton(
                          onPressed: () {
                            takePayment(context);
                          },
                          child: const Text("Take Payment"))),*/
          ],
        ),
        /* SizedBox(
          height: 30,
          child: SwipeableButtonView(
            buttonText: 'Start Order',
            buttonWidget: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
            ),
            activeColor: const Color(0xFFB71C1C),
            isFinished: isFinished,
            onWaitingProcess: () {
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  isFinished = false;
                });
              });
            },
            onFinish: () async {
              setState(() {
                isFinished = false;
              });
            },
          ),
        )*/
      ],
    ));
  }

  t2pWeightUpdateDialog(String orderId) {
    OrderController controller = Get.find();

    TextEditingController weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: DefaultDialog(
        message: "Enter product weight",
        btn1Txt: "Update",
        btn1Click: () {
          if (formKey.currentState!.validate()) {
            Get.back();
            controller.updateT2POrderWeight(orderId, weightController.text);
          }
        },
        btn2Txt: "Cancel",
        btn2Click: () {
          Get.back();
        },
        icon: TextFormField(
          controller: weightController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(label: Text("Enter Weight")),
          validator: (value) {
            if (value!.isEmpty) {
              return "Enter Weight";
            }
            return null;
          },
        ),
      ),
    );
  }

  verticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey,
    );
  }

  void launchDialer(String phoneNumer) async {
    String url = "tel:$phoneNumer";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url,));
    } else {
      throw 'Could not launch $url';
    }
  }
}
