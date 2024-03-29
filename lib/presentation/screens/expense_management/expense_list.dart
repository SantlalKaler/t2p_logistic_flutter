import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/single_cod_expense.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../widgets/app_back_button.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/app_scaffold.dart';
import 'add_edit_expense_screen.dart';
import 'expense_controller.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  ExpenseController expenseController = Get.find();

  @override
  void initState() {
    expenseController.getExpenseList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: appBar(title: "Expense List", leading: const AppBackButton()),
      body: GetBuilder<ExpenseController>(
        init: ExpenseController(),
        builder: (controller) {
          return controller.isLoading.isTrue
              ? circularloadingRedSmallInfinitySize()
              : controller.expenses.isEmpty
                  ? const AppEmptyView(message: "No Expense Data Found",)
                  : ListView.separated(
                      itemCount: controller.expenses.length,
                      padding: EdgeInsets.all(DimensConstants.screePadding),
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: DimensConstants.spaceBetweenViews,
                        );
                      },
                      itemBuilder: (context, index) {
                        return SingleExpenseItem(expense: controller.expenses[index],);
                      },
                    );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddEditExpenseScreen());
        },
        child: const Icon(Icons.add_box),
      ),
    );
  }
}
