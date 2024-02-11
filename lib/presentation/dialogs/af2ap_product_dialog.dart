import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/presentation/dialogs/otp_dialog.dart';
import 'package:t2p_logistic/presentation/dialogs/update_af2ap_dialog.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';

import 'default_dialog.dart';

class AF2APProductDialog extends StatefulWidget {
  final CommonOrder order;

  const AF2APProductDialog({super.key, required this.order});

  @override
  State<AF2APProductDialog> createState() => _AF2APProductDialogState();
}

class _AF2APProductDialogState extends State<AF2APProductDialog> {
  OrderController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    var products = widget.order.af2apProducts!;
    return GetBuilder(
        init: OrderController(),
        builder: (controller) => DefaultDialog(
              icon: Column(
                children: [
                const Text("Tap on any product to update its weight, height, length, and width."),
                  const Divider(),
                  for(var i = 0; i < products.length; i++)
                    ListTile(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context) => UpdateAF2APDialog(order: widget.order, index: i,),
                        );
                      },
                      leading: Text((i+1).toString()),
                      title: Text(
                        products[i].name ?? "",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    )
                ],
              ),
              btn2Txt: "Cancel",
              btn2Click: () {
                Get.back();
              },
              btn1Txt: "Done",
              btn1Click: () async {
                Get.back();
                controller.clearList(controller.t2pOrderType, controller.orderType);
                controller.getOrders();
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
