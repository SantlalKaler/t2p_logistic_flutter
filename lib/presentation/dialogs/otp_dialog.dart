import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/enums/other.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import 'default_dialog.dart';

class OTPDialog extends StatefulWidget {
  const OTPDialog({
    super.key,
  });

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  OrderController controller = Get.find();
  UserController userController = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Obx(() => DefaultDialog(
            icon: Column(
              children: [
                TextFormField(
                  controller: controller.otpController,
                  keyboardType: TextInputType.phone,
                  maxLength: 6,
                  decoration: const InputDecoration(label: Text("OTP")),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return "Enter Valid OTP";
                    }
                    return null;
                  },
                ),
                Gap(DimensConstants.spaceBetweenViews),
                if (controller.t2pOrderType == T2POrderType.AF2AP)
                  TextFormField(
                    controller: controller.paidAmountController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(label: Text("Paid Amount")),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter amount that customer pays.";
                      }
                      return null;
                    },
                  ),
                TextButton(
                    onPressed: () async {
                      (controller.t2pOrderType == T2POrderType.T2P &&
                              controller.orderType == OrderType.pickup)
                          ? await controller.sendOTPToCargo()
                          : (controller.t2pOrderType == T2POrderType.AF2AP)
                              ? await controller.sendOTPToCustomerAF2AP()
                              : await controller
                                  .sendOTPToCustomer(userController.orderId!);
                    },
                    child: controller.dialogLoading.isTrue
                        ? circularloadingRedSmall()
                        : const Text("Resend OTP"))
              ],
            ),
            // message: "Enter otp",
            btn2Txt: "Cancel",
            btn2Click: () {
              Get.back();
            },
            btn1Txt: "Submit",
            btn1Click: () async {
              if (_formKey.currentState!.validate()) {
                Get.back();
                (controller.t2pOrderType == T2POrderType.AF2AP &&
                        controller.orderType == OrderType.deliver)
                    ? await controller.orderDeliveredAF2AP()
                    : (controller.t2pOrderType == T2POrderType.AF2AP &&
                            controller.orderType == OrderType.pickup)
                        ? await controller.orderPickedUpAF2AP()
                        : await controller.orderDelivered();
              }
            },
          )),
    );
  }
}
