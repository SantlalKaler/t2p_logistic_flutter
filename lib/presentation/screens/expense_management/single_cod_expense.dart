import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/add_edit_expense_screen.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';

import '../../../domain/Model/expense/ExpenseListResponse.dart';
import '../../theme/resource/dimens.dart';
import '../../widgets/app_container.dart';
import '../../widgets/date_chooser.dart';

class SingleExpenseItem extends StatelessWidget {
  final Expense expense;

  const SingleExpenseItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    ExpenseController controller = Get.find();

    return AppContainer(
        child: Padding(
      padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              datePickerView(expense.createdDate!.toDate()),
              datePickerView(expense.createdDate!.toDate(outputDate: 'HH:mm')),
            ],
          ),
          Text("\nAdded By : ${expense.addedBy?.fullName}\n"),
          Text("Name : ${expense.name}\n"),
          Text("Category : ${expense.category?.name}\n"),
          Text("Subcategory : ${expense.subCategory?.name}\n"),
          Text("City : ${expense.city?.name}\n"),
          Text("Amount : Rs.${expense.amount}\n"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             /* Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  *//*  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(status.color),
                      elevation: MaterialStateProperty.all(0)),*//*
                  child: Text(
                    " status.name ?? " "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Gap(DimensConstants.spaceBetweenViews),
              */
              Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      Get.to(AddEditExpenseScreen(
                        expense: expense,
                      ));
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
