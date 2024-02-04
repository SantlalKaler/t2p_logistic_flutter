import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/address/address_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_back_button.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/app_scaffold.dart';
import 'add_edit_address_screen.dart';
import 'address_cards.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  AddressController addressController = Get.find();

  @override
  void initState() {
    addressController.getAddressList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: AddressController(),
        builder: (controller) {
          return AppScaffold(
            appBar: appBar(title: "My Address", leading: const AppBackButton()),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.to(const AddEditAddress(
                  isEdit: false,
                  redirectToHome: false,
                ));
              },
              child: const Icon(Icons.add_home),
            ),
            body: controller.isLoading.isTrue
                ? circularloadingRedSmallInfinitySize()
                : controller.addressList.isEmpty
                    ? const AppEmptyView(message: "No Address Found")
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          return addressCard(
                            context,
                            controller.addressList[index],
                            showEditDeleteActions: true
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: DimensConstants.spaceBetweenViewsAndSubViews,);
                        },
                        itemCount: controller.addressList.length),
          );
        });
  }
}
