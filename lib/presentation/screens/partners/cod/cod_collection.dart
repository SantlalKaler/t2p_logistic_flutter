import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_container.dart';
import 'package:t2p_logistic/presentation/widgets/date_chooser.dart';

import '../../../widgets/app_scaffold.dart';
import 'add_cod.dart';

class CodCollectionScreen extends StatefulWidget {
  const CodCollectionScreen({super.key});

  @override
  State<CodCollectionScreen> createState() => _CodCollectionScreenState();
}

class _CodCollectionScreenState extends State<CodCollectionScreen> {
  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
            title: "Cod Collection",
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        Column(
          children: [
            dateChooser(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(DimensConstants.screePadding),
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return singleCodCollectionItem();
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: DimensConstants.spaceBetweenViews,
                      );
                    },
                    itemCount: 10),
              ),
            )
          ],
        ));
  }

  singleCodCollectionItem() {
    return appContainer(Padding(
      padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              datePickerView("Date"),
              datePickerView("Time"),
            ],
          ),
          const Text("Added by\n"),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Delivery Date"), Text("Delivery Time")],
          ),
          const Text("\nAction by\n"),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order Id"),
              Text(
                "Order Status",
                style: TextStyle(color: Colors.green),
              )
            ],
          ),
          const Text("\nAmount\n"),
          const Text("City\n"),
              ElevatedButton(onPressed: () {
                Get.to(const AddCodScreen());
              }, child: const Text("Edit")),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //const Text("Status\n"),
            ],
          )*/
        ],
      ),
    ));
  }
}
