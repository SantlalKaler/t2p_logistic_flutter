import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/partner/CodExpenseListResponse.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../dialogs/date_picker_dialog.dart';
import '../../../theme/resource/custom_constants.dart';
import '../../../widgets/app_container.dart';
import '../../../widgets/app_image_picker.dart';
import '../boy/add_delivery_boy.dart';

class AddCodScreen extends StatefulWidget {
  final CodExpense expense;

  const AddCodScreen({super.key, required this.expense});

  @override
  State<AddCodScreen> createState() => _AddCodScreenState();
}

class _AddCodScreenState extends State<AddCodScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController orderNumberController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController paymentController = TextEditingController();
  TextEditingController dateOfPaymentController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController deliveryBoyController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  CodCollectionController controller = Get.find();

  @override
  void initState() {
    controller.getListLogisticBoy();
    var expense = widget.expense;
    orderNumberController.text = expense.number ?? "";
    cityController.text = expense.city?.name ?? "";
    amountController.text = expense.amount ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
            title: "Edit Cod",
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        GetBuilder(
            init: CodCollectionController(),
            builder: (controller) {
              return Padding(
                padding: EdgeInsets.all(DimensConstants.screePadding),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        appContainer(Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: orderNumberController,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                      label: Text("Order Number")),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter first name";
                                    }
                                    return null;
                                  },
                                ),
                                Gap(DimensConstants.spaceBetweenViews),
                                TextFormField(
                                  enabled: false,
                                  controller: cityController,
                                  decoration: const InputDecoration(
                                      label: Text("City")),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter email";
                                    }
                                    return null;
                                  },
                                ),
                                Gap(DimensConstants.spaceBetweenViews),
                                DropdownMenu(
                                  expandedInsets: const EdgeInsets.all(0),
                                  controller: deliveryBoyController,
                                  hintText: 'Delivery Boy',
                                  onSelected: (value) {
                                    if (value != null) {
                                      controller.selectedDeliveryBoy.value =
                                          value.toString();
                                    }
                                  },
                                  inputDecorationTheme:
                                      Theme.of(context).inputDecorationTheme,
                                  dropdownMenuEntries: [
                                    for (var item in controller.boyList)
                                      DropdownMenuEntry(
                                          value: item.id, label: item.fullName!)
                                  ],
                                ),
                                Gap(DimensConstants.spaceBetweenViews),
                                TextFormField(
                                  enabled: false,
                                  controller: amountController,
                                  decoration: const InputDecoration(
                                      label: Text("Amount")),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter mobile";
                                    }
                                    return null;
                                  },
                                ),
                                Gap(DimensConstants.spaceBetweenViews),
                                TextFormField(
                                  controller: paymentController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                      label: Text("Payment Received")),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter mobile";
                                    }
                                    return null;
                                  },
                                ),
                                Gap(DimensConstants.spaceBetweenViews),
                                GestureDetector(
                                  onTap: () {
                                    showDatePickerDialog(context, (value) {
                                      if (value != null) {
                                        dateOfPaymentController.text = value;
                                      }
                                    });
                                  },
                                  child: TextFormField(
                                    enabled: false,
                                    controller: dateOfPaymentController,
                                    decoration: const InputDecoration(
                                        label: Text("Date of payment"),
                                        suffixIcon: Icon(Icons.calendar_month)),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter mobile";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Gap(DimensConstants.spaceBetweenViews),
                                GestureDetector(
                                  onTap: () {
                                    showOptions(context, (source) {
                                      pickImage(source, (name, path) {
                                        controller.setDocumentImages(
                                            name, path);
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
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter mobile";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Gap(DimensConstants.spaceBetweenViews),
                                TextFormField(
                                  enabled: false,
                                  controller: remarksController,
                                  decoration: const InputDecoration(
                                    label: Text("Remarks"),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter mobile";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ))),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                          onPressed: () {
                            if (deliveryBoyController.text.isEmpty ||
                                dateOfPaymentController.text.isEmpty ||
                                paymentController.text.isEmpty) {
                              CustomSnackBar.showSnackBar(CustomSnackBar.error,
                                  "Please fill all data", CustomSnackBar.error);
                            } else {
                              //printValue("server data : ${dateOfPaymentController.text.toServerDate()}");
                              controller.updateCodExpense(
                                  paymentController.text,
                                  dateOfPaymentController.text,
                                  deliveryBoyController.text,
                                  widget.expense.id!,
                                  remarksController.text);
                            }
                          },
                          child: controller.loading.isTrue
                              ? circularloadingWhiteSmall()
                              : const Text("Edit Cod Expense")),
                    )
                  ],
                ),
              );
            }));
  }
}
