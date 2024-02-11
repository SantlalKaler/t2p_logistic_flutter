import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:t2p_logistic/domain/enums/user_type.dart';
import 'package:t2p_logistic/presentation/dialogs/otp_dialog.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/theme/resource/image_constants.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../widgets/app_image.dart';
import 'default_dialog.dart';

class CODDialog extends StatefulWidget {
  const CODDialog({
    super.key,
  });

  @override
  State<CODDialog> createState() => _CODDialogState();
}

class _CODDialogState extends State<CODDialog> {
  OrderController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: OrderController(),
        builder: (controller) => DefaultDialog(
              icon: Column(
                children: [
                  RadioListTile(
                      value: PaymentType.COD.name,
                      title: Text(
                        PaymentType.COD.name,
                      ),
                      groupValue: controller.paymentType.name,
                      onChanged: (v) {
                        if (v != null) {
                          controller.changePaymentType(PaymentType.COD);
                        }
                      }),
                  RadioListTile(
                      value: PaymentType.QR.name,
                      title: Text(
                        PaymentType.QR.name,
                      ),
                      groupValue: controller.paymentType.name,
                      onChanged: (v) {
                        if (v != null) {
                          controller.changePaymentType(PaymentType.QR);
                        }
                      }),
                  RadioListTile(
                      value: PaymentType.Link.name,
                      title: Text(
                        PaymentType.Link.name,
                      ),
                      groupValue: controller.paymentType.name,
                      onChanged: (v) {
                        if (v != null) {
                          controller.changePaymentType(PaymentType.Link);
                        }
                      }),
                  Obx(() => controller.dialogLoading.isTrue
                      ? circularloadingRedSmall()
                      : controller.qrAvailable.value.isNotEmpty &&
                              controller.paymentType == PaymentType.QR
                          ? Column(
                              children: [
                                Gap(DimensConstants
                                    .spaceBetweenViewsAndSubViews),
                                getAssetImage(ImageConstants.appIconSmall),
                                Gap(DimensConstants
                                    .spaceBetweenViewsAndSubViews),
                                SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: QrImageView(
                                    data: controller.qrAvailable.value,
                                    version: QrVersions.auto,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink())
                ],
              ),
              // message: "Enter otp",
              btn2Txt: "Cancel",
              btn2Click: () {
                //if (controller.paymentType == PaymentType.QR) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CancelPaymentDialog();
                  },
                );
                /* } else {
                  Get.back();
                }*/
              },
              btn1Txt: "Submit",
              btn1Click: () async {
                if (controller.paymentType == PaymentType.QR) {
                  await controller.checkPaymentStatus();
                  if (controller.phonePePaymentSuccess.isTrue) {
                    //close cod dialog and show otp dialog
                    Get.back();
                    if (context.mounted) {
                      showCodDialog();
                    }
                  }
                } else {
                  Get.back();
                  showCodDialog();
                }
              },
            ));
  }

  showCodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const OTPDialog();
      },
    );
  }
}

class CancelPaymentDialog extends StatefulWidget {
  const CancelPaymentDialog({super.key});

  @override
  State<CancelPaymentDialog> createState() => _CancelPaymentDialogState();
}

class _CancelPaymentDialogState extends State<CancelPaymentDialog> {
  OrderController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      message: "Are you sure you want to cancel?",
      btn1Txt: "Yes",
      btn1Click: () async {
        Get.back();
        await controller.cancelPayment();
      },
      btn2Txt: "No",
      btn2Click: () {
        Get.back();
      },
    );
  }
}
