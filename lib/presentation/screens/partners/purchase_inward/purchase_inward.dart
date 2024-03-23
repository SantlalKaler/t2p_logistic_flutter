import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/partner/purchase_inward/PurchaseInwardListResponse.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/screens/partners/purchase_inward/purchase_inward_controller.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../../../domain/Model/partner/purchase_inward/update_inward.dart';
import '../../../theme/resource/dimens.dart';
import '../../../widgets/app_back_button.dart';
import '../../../widgets/app_container.dart';
import '../../../widgets/date_chooser.dart';

class PurchaseInwardList extends StatefulWidget {
  const PurchaseInwardList({super.key});

  @override
  State<PurchaseInwardList> createState() => _PurchaseInwardListState();
}

class _PurchaseInwardListState extends State<PurchaseInwardList> {
  PurchaseInwardController purchaseInwardController = Get.find();

  @override
  void initState() {
    purchaseInwardController.getInwardList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              pinned: true,
              floating: true,
              title: Text("Purchase Inward"),
              leading: AppBackButton(),
            )
          ];
        },
        body: GetBuilder<PurchaseInwardController>(
            init: PurchaseInwardController(),
            builder: (controller) {
              return controller.loading.isTrue
                  ? circularloadingRedSmallInfinitySize()
                  : controller.inwardList.isEmpty
                  ? const AppEmptyView(
                message: "No Data Found",
              )
                  : ListView.separated(
                  padding: EdgeInsets.all(DimensConstants.screePadding),
                  itemBuilder: (context, index) {
                    return SingleInwardItem(
                      inward: controller.inwardList[index],
                      onEdit: () {
                        controller.getSingleInward(controller.inwardList[index]
                            .id!);
                        Get.to(() => const UpdateInwardScreen());
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: DimensConstants.spaceBetweenViews,
                    );
                  },
                  itemCount: controller.inwardList.length);
            }),
      ),
    );
  }
}

class SingleInwardItem extends StatelessWidget {
  final Inward inward;
  final Function onEdit;

  const SingleInwardItem(
      {super.key, required this.inward, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    bool approved = inward.approved == 1 ? true : false;

    return AppContainer(
        child: Padding(
          padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "${inward.createdDate!.toDate(
                          outputDate: "dd-MM-yyyy, HH:mm")}\n"),
                  Text("${inward.poId}\n"),
                ],
              ),
              Text("Inward To : ${inward.inwardOffice?.name}\n"),
              Text("Bill Number : ${inward.billNo}\n"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Rs. ${inward.amount}\n"),
                  Text("Type : ${inward.type == 0 ? "IN" : "OUT"}\n"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Icon(
                      approved ? Icons.thumb_up : Icons.thumb_down,
                      color: approved ? Colors.green : Colors.red,
                    ),
                  ),
                  Gap(DimensConstants.spaceBetweenViews),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          onEdit();
                        }, child: const Text("Edit")),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
