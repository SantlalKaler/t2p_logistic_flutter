import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/single_filter_item.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';

import '../../../../../domain/Model/partner/CodExpenseListResponse.dart';

class CodChipList extends StatelessWidget {
  const CodChipList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: CodCollectionController(),
        builder: (controller) {
          return SizedBox(
            height: 50,
            child: ListView.builder(
              itemCount: controller.chipList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var chip = controller.chipList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Chip(
                    label: Text(chip.title),
                    backgroundColor: Colors.white,
                    deleteIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.red,
                    ),
                    onDeleted: () {
                      if (chip.id == FilterItemId.city) {
                        showCityOrStatus(context, chip.id,
                            cityList: controller.cityList);
                      }
                      if (chip.id == FilterItemId.status) {
                        showCityOrStatus(
                          context,
                          chip.id,
                        );
                      }
                      if (chip.id == FilterItemId.startDate) {
                        showCalendar(context, FilterItemId.startDate);
                      }
                      if (chip.id == FilterItemId.endDate) {
                        showCalendar(context, FilterItemId.endDate);
                      }
                    },
                  ),
                );
              },
            ),
          );
        });
  }

  showCalendar(BuildContext context, FilterItemId itemId) async {
    CodCollectionController controller = Get.find();
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime(2020, 8),
        lastDate: DateTime.now());
    if (picked != null && controller.selectedStartDate.value != picked) {
      controller.setSelectedItem(itemId, date: picked);
    }
  }

  showCityOrStatus(BuildContext context, FilterItemId itemId,
      {List<City>? cityList}) {
    CodCollectionController controller = Get.find();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return ListView.builder(
          itemCount: cityList?.length ?? controller.statusList.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(
                  (cityList?[index].name ?? controller.statusList[index].name!)
                      .toUpperCase(),
                ),
                onTap: () {
                  controller.setSelectedItem(itemId, index: index);
                  Get.back();
                });
          },
        );
      },
    );
  }
}
