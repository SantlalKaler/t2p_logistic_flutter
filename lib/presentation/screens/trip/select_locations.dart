import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/presentation/screens/trip/trip_controller.dart';

import '../address/address_cards.dart';
import '../address/address_controller.dart';

class SelectLocationWidget extends StatelessWidget {
  const SelectLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    TripController tripController = Get.find();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(
          () => locationWidget(
            context,
            tripController.pickupAddress.value,
            isPickup: true,
          ),
        ),
        Obx(
          () => locationWidget(
            context,
            tripController.destinationAddress.value,
            isPickup: false,
          ),
        ),
      ],
    );
  }

  Widget locationWidget(
    BuildContext context,
    Address address, {
    bool isPickup = true,
  }) {
    TripController tripController = Get.find();

    return GestureDetector(
      onTap: () {
        Get.bottomSheet(selectAddressSheet(context, isPickup));
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          width: double.infinity,
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                isPickup ? Icons.local_activity : Icons.add,
                color: isPickup
                    ? Theme.of(context).primaryColor
                    : const Color(0xFF067647),
                size: 26,
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPickup ? 'Pickup Location' : 'Destination Location',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xFF182230),
                        fontSize: 15,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      (isPickup
                          ? tripController.pickupAddress.value.id == null
                                ? ('Tap here to select a pickup location')
                                : '${address.contactName}\n${address.address}\n+91-${address.contactMobile}\n${address.city!.name} (${address.pincode})'
                          : tripController.destinationAddress.value.id == null
                          ? ('Tap here to select a destination location')
                          : '${address.contactName}\n${address.address}\n+91-${address.contactMobile}\n${address.city!.name} (${address.pincode})'),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: const Color(0xFF667085),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectAddressSheet(BuildContext context, isPickup) {
    AddressController addressController = Get.find();
    TripController tripController = Get.find();

    addressController.getAddressList();

    return BottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onClosing: () {},
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Text(
                isPickup
                    ? 'Select pickup address'
                    : 'Select destination location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(20),
              for (var item in addressController.addressList)
                GestureDetector(
                  onTap: () {
                    if (isPickup) {
                      tripController.pickupAddress.value = item;
                      tripController.destinationAddress.value =
                          Address(); //reset destination
                    } else {
                      tripController.destinationAddress.value = item;
                    }
                    Get.back();
                  },
                  child:
                      // condition for hiding slected pickup location from destination select address list
                      (!isPickup &&
                          tripController.pickupAddress.value.id == item.id)
                      ? const SizedBox.shrink()
                      : addressCard(context, item, showDefaultMark: false),
                ),
            ],
          ),
        );
      },
    );
  }
}
