import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/trip/add_trip.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
            title: "My Trips",
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        Stack(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text("No Trip Found"),
            ),
            Padding(
              padding: EdgeInsets.all(DimensConstants.screePadding),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () {
                        Get.to(()=> const AddTripScreen());
                      }, child: const Text("Add New Trip"))),
            )
          ],
        ));
  }
}
