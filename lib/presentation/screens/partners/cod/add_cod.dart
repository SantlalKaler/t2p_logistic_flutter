import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';

import '../../../widgets/app_container.dart';

class AddCodScreen extends StatefulWidget {
  const AddCodScreen({super.key});

  @override
  State<AddCodScreen> createState() => _AddCodScreenState();
}

class _AddCodScreenState extends State<AddCodScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
             title: "Add Cod",
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        Padding(
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
                            controller: nameController,
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
                            controller: nameController,
                            decoration:
                                const InputDecoration(label: Text("City")),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter email";
                              }
                              return null;
                            },
                          ),
                          Gap(DimensConstants.spaceBetweenViews),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                label: Text("Delivery Boy")),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter mobile";
                              }
                              return null;
                            },
                          ),
                          Gap(DimensConstants.spaceBetweenViews),
                          TextFormField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(label: Text("Amount")),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter mobile";
                              }
                              return null;
                            },
                          ),
                          Gap(DimensConstants.spaceBetweenViews),
                          TextFormField(
                            controller: nameController,
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
                          TextFormField(
                            controller: nameController,
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
                          Gap(DimensConstants.spaceBetweenViews),
                          TextFormField(
                            controller: nameController,
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
                          const Text("\nFile\n\nFileName")
                        ],
                      ))),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    }, child: const Text("Add Cod Expense")),
              )
            ],
          ),
        ));
  }
}
