import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/partner/FinancialLogResponse.dart';
import 'package:t2p_logistic/domain/Model/partner/Pair.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/screens/partners/financial_log/financial_log_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/strings_constants.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../../theme/resource/dimens.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/date_chooser.dart';

class FinancialLogs extends StatefulWidget {
  const FinancialLogs({super.key});

  @override
  State<FinancialLogs> createState() => _FinancialLogsState();
}

class _FinancialLogsState extends State<FinancialLogs> {
  FinancialLogController financialLogController = Get.find();

  var painAmount = 0.0;
  var unPainAmount = 0.0;

  @override
  void initState() {
    financialLogController.financialLog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: FinancialLogController(),
        builder: (controller) {
          return AppScaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  AppBarSliver(
                    title: "Financial Log",
                    bottom: appBarBottom(),
                  ),
                ];
              },
              body: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(DimensConstants.screePadding),
                      child: controller.isLoading.isTrue
                          ? circularloadingRedSmallInfinitySize()
                          : controller.logList.isEmpty
                          ? const AppEmptyView(message: "No Data Found.",)
                          :ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return singleLog(controller.logList[index]);
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: DimensConstants.spaceBetweenViews,
                                );
                              },
                              itemCount: controller.logList.length),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  appBarBottom() {
    for (var item in financialLogController.logList) {
      if (item.commission!.toDouble() > 0.0) {
        painAmount += item.commission!.toDouble();
      } else {
        unPainAmount -= item.commission!.toDouble();
      }
    }

    return PreferredSize(
        preferredSize: const Size(double.infinity, 55),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            datePickerView(
                "Unpaid Amount\n${StringConstants.rupeeSign} $unPainAmount"),
            datePickerView(
                "Paid Amount\n${StringConstants.rupeeSign} $painAmount")
          ],
        ));
  }

  singleLog(FinancialLog log) {
    var itemList = [
      Pair(key: "Order Id", value: log.orderid ?? ""),
      Pair(key: "Amount", value: log.commission.toString()),
      Pair(key: "Distance", value: log.distance.toString()),
      Pair(key: "Created At", value: log.createdDate!.toDate()),
      Pair(key: "Update At", value: log.createdDate!.toDate()),
    ];

    printValue(itemList);
    return Container(
      padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var item = itemList[index];
            return RichText(
                text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                  TextSpan(
                      text: item.key,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                    text: " : ${item.value}",
                  ),
                ]));
          },
          separatorBuilder: (context, index) {
            return Gap(DimensConstants.spaceBetweenViewsAndSubViews);
          },
          itemCount: itemList.length),
    );
  }
}
