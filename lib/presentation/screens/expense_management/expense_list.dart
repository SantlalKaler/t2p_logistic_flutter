import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_back_button.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/app_scaffold.dart';
import 'add_edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: appBar(title: "Expense List", leading: const AppBackButton()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddEditExpenseScreen());
        },
        child: const Icon(Icons.add_box),
      ),
    );
  }
}
