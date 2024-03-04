import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';

import '../../../../theme/resource/color_constant.dart';
import '../../../../theme/resource/dimens.dart';
import 'cod_chip_list.dart';

PreferredSize codAppBarBottom(){
  CodCollectionController controller = Get.find();
  return PreferredSize(
      preferredSize: const Size(double.infinity, 140),
      child: Column(
        children: [
          Obx(() => Container(
            padding: EdgeInsets.symmetric(
                vertical: DimensConstants.spaceBetweenViews),
            child: Text(
              "Cod Expense [Total collections : Rs. ${controller.totalExpense.value}",
              style: const TextStyle(color: Colors.white),
            ),
          )),
          Container(
              width: double.infinity,
              color: ColorConstants.screenBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CodChipList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("Search"))),
                      Gap(DimensConstants.spaceBetweenViews),
                      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("Reset"))),
                    ],
                  )
                ],
              )),

        ],
      ));
}
