import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/domain/mapper/product_mapper.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../domain/Model/AF2APOrderResponse.dart';
import '../../domain/Model/AF2APUpdateProduct.dart' as updateProduct;
import 'default_dialog.dart';

class UpdateAF2APDialog extends StatefulWidget {
  final CommonOrder order;
  final int index;

  const UpdateAF2APDialog(
      {super.key, required this.order, required this.index});

  @override
  State<UpdateAF2APDialog> createState() => _UpdateAF2APDialogState();
}

class _UpdateAF2APDialogState extends State<UpdateAF2APDialog> {
  OrderController controller = Get.find();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController lengthController = TextEditingController();

  @override
  void initState() {
    printValue(widget.order.af2apProducts![widget.index].weight);

    Products product = widget.order.af2apProducts![widget.index];

    weightController.text = product.weight ?? "";
    heightController.text = product.height ?? "";
    widthController.text = product.weidth ?? "";
    lengthController.text = product.length ?? "";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: OrderController(),
        builder: (controller) => DefaultDialog(
              //message: "Enter ",
              btn1Txt: "Update",
              btn1Click: () async {
                if (controller.buttonLoading.isFalse) {
                  // replace product with updates
                  updateProductList();
                }
              },
              btn2Txt: "Cancel",
              btn2Click: () {
                if (controller.buttonLoading.isFalse) {
                  Get.back();
                }
              },
              icon: Column(
                children: [
                  TextFormField(
                    controller: weightController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(label: Text("Enter Weight")),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Weight";
                      }
                      return null;
                    },
                  ),
                  Gap(DimensConstants.spaceBetweenViews),
                  TextFormField(
                    controller: lengthController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        label: Text("Enter Length(Optional)")),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Length";
                      }
                      return null;
                    },
                  ),
                  Gap(DimensConstants.spaceBetweenViews),
                  TextFormField(
                    controller: heightController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        label: Text("Enter Height(Optional)")),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Height";
                      }
                      return null;
                    },
                  ),
                  Gap(DimensConstants.spaceBetweenViews),
                  TextFormField(
                    controller: widthController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        label: Text("Enter Width(Optional)")),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Width";
                      }
                      return null;
                    },
                  ),
                  controller.dialogLoading.isTrue
                      ? circularloadingRedSmall()
                      : const SizedBox.shrink()
                ],
              ),
            ));
  }

  updateProductList() async {
    var productList = widget.order.af2apProducts!;
    var product = widget.order.af2apProducts![widget.index];
    product = product.copyWith(
      weidth: widthController.text,
      weight: weightController.text,
      height: heightController.text,
      length: lengthController.text,
    );

    productList[widget.index] = product;

    List<updateProduct.Products> updateProductList = [];
    for (product in productList) {
      updateProductList.add(product.toAF2APUpdateProduct());
    }

    String updatedValue = updateProduct.af2apUpdateProductToJson(
        updateProduct.Af2apUpdateProduct(
            orderId: widget.order.orderId, products: updateProductList));

    await controller.updateAF2APOrderWeight(
        updatedValue, widget.order.orderId!);
  }
}
