import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';

import '../../../../theme/resource/dimens.dart';
import 'cod_chip_list.dart';

PreferredSize codAppBarBottom() {
  CodCollectionController controller = Get.find();
  return /* controller.filterCodExpenseList.isEmpty
      ? PreferredSize(preferredSize: const Size(0, 0), child: Container())
      : */ PreferredSize(
    preferredSize: const Size(double.infinity, 178),
    child: Column(
      children: [
        Obx(
          () => Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Cod Expense [Total collections : Rs. ${controller.totalExpense.value}",
              style: const TextStyle(
                color: Color(0xFFB42332),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CodChipList(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DimensConstants.screePadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.getCodExpenseList();
                        },
                        child: const Text("Search"),
                      ),
                    ),
                    Gap(DimensConstants.spaceBetweenViews),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.clearFilter();
                        },
                        child: const Text("Reset"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
