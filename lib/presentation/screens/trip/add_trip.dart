import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/trip/select_locations.dart';
import 'package:t2p_logistic/presentation/screens/trip/trip_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_back_button.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final TextEditingController remarksController = TextEditingController();
  TripController tripController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: appBar(leading: const AppBackButton(), title: "Add Trip"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: DimensConstants.screePadding),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SelectLocationWidget(),
                  Gap(DimensConstants.spaceBetweenViews),
                  TextFormField(
                    style: Theme.of(context).textTheme.titleSmall,
                    controller: remarksController,
                    decoration: const InputDecoration(
                        label: Text(
                          'Remarks',
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter remarks';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(() => ElevatedButton(
                  onPressed: () async {
                    if (tripController.pickupAddress.value.id == null ||
                        tripController.pickupAddress.value.id?.isEmpty ==
                            true ||
                        tripController.destinationAddress.value.id == null ||
                        tripController.destinationAddress.value.id?.isEmpty ==
                            true) {
                      CustomSnackBar.showSnackBar(CustomSnackBar.error,
                          "Please select both address", CustomSnackBar.error);
                    } else {
                     // await tripController.getDistanceByRoad();
                    }
                  },
                  child: tripController.isLoading.isTrue
                      ? circularloadingWhiteSmall()
                      : const Text("Start"))),
            )
          ],
        ),
      ),
    );
  }
}
