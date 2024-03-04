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
                        showCityOrStatus(context,
                            cityList: controller.cityList);
                      }
                      if (chip.id == FilterItemId.status) {
                        showCityOrStatus(
                          context,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        });
  }

  showCityOrStatus(BuildContext context, {List<City>? cityList}) {
    CodCollectionController controller = Get.find();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  controller.clearCityFilter();
                  Get.back();
                },
                child: const Text("Clear")),
            Expanded(
              child: ListView.builder(
                itemCount: cityList?.length ?? controller.statusList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(
                        cityList?[index].name ??
                            controller.statusList[index].name!,
                      ),
                      onTap: () {
                        if (cityList != null) {
                          controller.filterByCity(cityList[index]);
                        }else{

                        }
                        Get.back();
                      });
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
