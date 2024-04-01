import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../domain/Model/expense/ExpenseListResponse.dart';
import '../../dialogs/date_picker_dialog.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/app_image_picker.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/circular_loadings.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key, this.expense});

  final Expense? expense;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
  TextEditingController officeTypeController = TextEditingController();
  TextEditingController officeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController dateOfPaymentController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  ExpenseController expenseController = Get.find();
  UserController userController = Get.find();

  @override
  void initState() {
    fillValue();
    expenseController.getCategories();
    super.initState();
  }

  fillValue() {
    if (widget.expense != null) {
      Expense expense = widget.expense!;
      categoryController.text = expense.category!.name!;
      subCategoryController.text = expense.subCategory!.name!;
      nameController.text = expense.name!;
      amountController.text = expense.amount!;
      dateOfPaymentController.text = expense.dateOfPayment!.toDate();
      commentController.text = expense.comment ?? "";
      expenseController.getSubCategories(expense.category!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
          appBar: appBar(
              title: widget.expense == null ? "Add Expense" : "Edit Expense",
              leading: const AppBackButton()),
          body: Padding(
            padding: EdgeInsets.all(DimensConstants.screePadding),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownMenu(
                          expandedInsets: const EdgeInsets.all(0),
                          controller: categoryController,
                          enabled: expenseController.isLoading.isFalse,
                          hintText: 'Category',
                          onSelected: (categoryId) {
                            if (categoryId != null) {
                              subCategoryController.clear();
                              expenseController.getSubCategories(categoryId);
                            }
                          },
                          inputDecorationTheme:
                              Theme.of(context).inputDecorationTheme,
                          dropdownMenuEntries: [
                            for (var item in expenseController.categories)
                              DropdownMenuEntry(
                                  value: item.id, label: item.name!)
                          ],
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        DropdownMenu(
                          expandedInsets: const EdgeInsets.all(0),
                          controller: subCategoryController,
                          hintText: 'Sub Category',
                          enabled: expenseController.isLoading.isFalse,
                          onSelected: (subCategoryId) {
                            if (subCategoryId != null) {}
                          },
                          inputDecorationTheme:
                              Theme.of(context).inputDecorationTheme,
                          dropdownMenuEntries: [
                            for (var item in expenseController.subCategories)
                              DropdownMenuEntry(
                                  value: item.id, label: item.name!)
                          ],
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        TextFormField(
                          style: Theme.of(context).textTheme.titleSmall,
                          controller: nameController,
                          decoration: const InputDecoration(
                              label: Text(
                                'Name',
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.auto),
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        /*  TextFormField(
                          style: Theme.of(context).textTheme.titleSmall,
                          controller: officeTypeController,
                          enabled: false,
                          decoration: const InputDecoration(
                              label: Text(
                                'Office Type',
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.auto),
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        TextFormField(
                          style: Theme.of(context).textTheme.titleSmall,
                          controller: officeController,
                          enabled: false,
                          decoration: const InputDecoration(
                              label: Text(
                                'Office',
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.auto),
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        TextFormField(
                          style: Theme.of(context).textTheme.titleSmall,
                          controller: cityController,
                          enabled: false,
                          decoration: const InputDecoration(
                              label: Text(
                                'City',
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.auto),
                        ),
                        Gap(DimensConstants.spaceBetweenViews),*/
                        TextFormField(
                          style: Theme.of(context).textTheme.titleSmall,
                          controller: amountController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter amount";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              label: Text(
                                'Amount',
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.auto),
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        GestureDetector(
                          onTap: () {
                            showDatePickerDialog(context, (value) {
                              printValue("Date of paymetn : $value");
                              if (value != null) {
                                dateOfPaymentController.text = value;
                              }
                            });
                          },
                          child: TextFormField(
                            enabled: false,
                            controller: dateOfPaymentController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter date of payment";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                label: Text("Date of payment"),
                                suffixIcon: Icon(Icons.calendar_month)),
                          ),
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        GestureDetector(
                          onTap: () {
                            showOptions(context, (source) {
                              pickImage(source, (name, path) {
                                expenseController.setDocumentImages(name, path);
                                documentController.text = path;
                              });
                            });
                          },
                          child: TextFormField(
                            enabled: false,
                            controller: documentController,
                            decoration: const InputDecoration(
                                label: Text("Document"),
                                suffixIcon: Icon(Icons.attach_file)),
                            /* validator: (value) {
                              if (value!.isEmpty) {
                                return "Select document";
                              }
                              return null;
                            },*/
                          ),
                        ),
                        Gap(DimensConstants.spaceBetweenViews),
                        TextFormField(
                          maxLines: 5,
                          controller: commentController,
                          decoration: const InputDecoration(
                            label: Text("Comment"),
                          ),
                        ),
                        const Gap(100),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addEditExpense();
                        }
                      },
                      child: expenseController.isLoading.isTrue
                          ? circularloadingWhiteSmall()
                          : Text(widget.expense == null
                              ? "Add Expense"
                              : "Edit Expense")),
                )
              ],
            ),
          ),
        ));
  }

  addEditExpense() async {
    if (categoryController.text.isEmpty || subCategoryController.text.isEmpty) {
      CustomSnackBar.showSnackBar("", "Select category and subcategory", "");
    } else {
      var category = expenseController.categories
          .firstWhere((element) => element.name == categoryController.text)
          .id!;
      var subCategory = expenseController.subCategories
          .firstWhere((element) => element.name == subCategoryController.text)
          .id!;

      if (widget.expense == null) {
        await expenseController.addExpense(
            category,
            subCategory,
            userController.userId,
            nameController.text,
            userController.userCity,
            amountController.text,
            dateOfPaymentController.text,
            commentController.text,
            userController.officeId,
            'local_office');
      } else {
        await expenseController.editExpense(
            widget.expense!.id!,
            category,
            subCategory,
            userController.userId,
            nameController.text,
            userController.userCity,
            amountController.text,
            dateOfPaymentController.text,
            commentController.text,
            userController.officeId,
            'local_office');
      }
    }
  }
}
