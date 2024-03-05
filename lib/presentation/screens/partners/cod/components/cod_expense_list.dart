import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/partner/CodExpenseListResponse.dart';
import 'package:t2p_logistic/domain/Model/partner/cod_collection_status.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';

import '../../../../theme/resource/dimens.dart';
import '../../../../widgets/app_container.dart';
import '../../../../widgets/date_chooser.dart';
import '../add_cod.dart';

class CodExpenseList extends StatelessWidget {
  const CodExpenseList({super.key});

  @override
  Widget build(BuildContext context) {
    CodCollectionController controller = Get.find();
    return ListView.separated(
        itemBuilder: (context, index) {
          return SingleCodCollectionItem(
              expense: controller.filterCodExpenseList[index]);
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: DimensConstants.spaceBetweenViews,
          );
        },
        itemCount: controller.filterCodExpenseList.length);
  }
}

class SingleCodCollectionItem extends StatelessWidget {
  final CodExpense expense;

  const SingleCodCollectionItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    CodCollectionController controller = Get.find();
    CodCollectionStatus status = controller.statusList[0];
    for (var statu in controller.statusList) {
      if (statu.id == expense.active) {
        status = statu;
      }
    }
    return appContainer(Padding(
      padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              datePickerView(expense.createdDate!.toDate()),
              datePickerView(expense.createdDate!.toDate(outputDate: "HH:mm")),
            ],
          ),
          Text("${expense.addedBy?.fullName}\n"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expense.orderId?.deliveryDate?.toDate() ?? ""),
              Text("${expense.orderId?.timeslot}\n")
            ],
          ),
          //const Text("\nAction by\n"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expense.number ?? ""),
              Text(
                expense.orderId?.status ?? "",
                style: const TextStyle(color: Colors.green),
              )
            ],
          ),
          Text("\nRs. ${expense.amount}\n"),
          Text("${expense.city?.name}\n"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(status.color),
                      elevation: MaterialStateProperty.all(0)),
                  child: Text(
                    status.name ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Gap(DimensConstants.spaceBetweenViews),
              if (expense.active != 4)
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        Get.to(AddCodScreen(expense: expense,));
                      },
                      child: const Text("Edit")),
                ),
            ],
          )
        ],
      ),
    ));
  }
}
