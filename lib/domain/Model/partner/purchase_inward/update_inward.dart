import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/partner/purchase_inward/SingleInwardResponse.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/purchase_inward/purchase_inward_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../../presentation/widgets/app_container.dart';

class UpdateInwardScreen extends StatefulWidget {
  const UpdateInwardScreen({super.key});

  @override
  State<UpdateInwardScreen> createState() => _UpdateInwardScreenState();
}

class _UpdateInwardScreenState extends State<UpdateInwardScreen> {
  final _formKey = GlobalKey<FormState>();

  PurchaseInwardController controller = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        appBar: appBar(
            title: "Edit Inward",
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        body: GetBuilder(
            init: PurchaseInwardController(),
            builder: (controller) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: DimensConstants.screePadding),
                child: controller.loading.isTrue
                    ? circularloadingRedSmallInfinitySize()
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Gap(DimensConstants.spaceBetweenViews),
                            inwardInfo(),
                            Gap(DimensConstants.spaceBetweenViews),
                            productList()
                          ],
                        ),
                      ),
              );
            }));
  }

  Widget inwardInfo() {
    return AppContainer(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.createdController,
          enabled: false,
          decoration: const InputDecoration(label: Text("Created")),
        ),
        Gap(DimensConstants.spaceBetweenViews),
        TextFormField(
          controller: controller.poIdController,
          enabled: false,
          decoration: const InputDecoration(label: Text("PO Id")),
        ),
        /*Gap(DimensConstants.spaceBetweenViews),
        TextFormField(
          controller: controller.orderIdController,
          enabled: false,
          maxLines: controller.orderIdController.text.isEmpty
              ? 1
              : controller.orderIdController.text.length ~/ 10,
          decoration: const InputDecoration(label: Text("Order Id")),
        ),*/
        Gap(DimensConstants.spaceBetweenViews),
        TextFormField(
          controller: controller.vendorCityController,
          enabled: false,
          decoration: const InputDecoration(label: Text("Vendor City")),
        ),
        Gap(DimensConstants.spaceBetweenViews),
        TextFormField(
          controller: controller.totalAmountController,
          enabled: false,
          decoration: const InputDecoration(label: Text("Total Amount")),
        ),
        Gap(DimensConstants.spaceBetweenViews),
      ],
    ));
  }

  Widget productList() {
    List<ResultProduct> products = controller.products;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        ResultProduct product = products[index];
        TextEditingController purchaseAmountController =
            TextEditingController();
        return Padding(
          padding: EdgeInsets.only(bottom: DimensConstants.spaceBetweenViews),
          child: AppContainer(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  /*  Image.network(
                    product.product!.file![0].location!,
                    height: 50,
                    width: 100,
                    fit: BoxFit.cover,
                  ),*/
                  Expanded(child: Text("${product.name}\n")),
                ],
              ),
              Text("Vendor : ${product.vendor?.fullName}\n"),
              Text(
                  "Total Price : Rs.${product.product?.price} * ${product.qty} = ${(product.qty ?? 1) * (product.product?.price ?? 10)}\n"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: purchaseAmountController,
                      enabled: true,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(label: Text("Purchase Price")),
                    ),
                  ),
                  Obx(() => IconButton(
                      onPressed: () {
                        controller.updateSingleProductPrice(
                            product.id!, purchaseAmountController.text);
                      },
                      icon: controller.updatePriceLoading.isTrue
                          ? circularloadingRedSmall()
                          : const Icon(
                              Icons.refresh,
                              color: Colors.red,
                            )))
                ],
              ),
            ],
          )),
        );
      },
    );
  }
}
