import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/presentation/screens/address/add_edit_address_screen.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';

import 'address_controller.dart';

Widget addressCard(BuildContext context, Address address,
    {bool? showEditDeleteActions, bool showDefaultMark = true}) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: DimensConstants.screePadding)
        .copyWith(top: DimensConstants.screePadding),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    address.contactName ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 16),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey.shade300),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      '${address.title}'.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                address.address ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 14),
              ),
              Text(
                address.address2 ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 14),
              ),
              Text(
                address.state!.name ?? "",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 14),
              ),
              Text(
                address.city!.name ?? "",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 14),
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  iconTile(Icons.location_on, address.pincode ?? ''),
                  iconTile(Icons.phone, '+91-${address.contactMobile}'),
                ],
              ),
              const Gap(10),
              showEditDeleteActions == true
                  ? Row(
                      children: [
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () {
                                  Get.to(AddEditAddress(
                                      address: address,
                                      isEdit: true,
                                      redirectToHome: false));
                                },
                                child: const Text('Edit'))),
                        const Gap(10),
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () {
                                  _showDeleteActionSheet(context, address.id);
                                },
                                child: const Text('Delete')))
                      ],
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ],
    ),
  );
}

Widget iconTile(IconData icon, String title) {
  return Row(
    children: [
      Icon(
        icon,
        size: 18,
        color: Colors.blueGrey,
      ),
      const Gap(5),
      Text(
        title,
      )
    ],
  );
}

void _showDeleteActionSheet(BuildContext context, addressId) {
  AddressController addressController = Get.find();
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Delete Address'),
      message: const Text('Are you sure you want to delete this address?'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () async {
            // await addressController.deleteAddress(addressId);
          },
          child: const Text('Delete'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
      ],
    ),
  );
}
