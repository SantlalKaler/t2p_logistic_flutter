import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/components/cod_expense_list.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_back_button.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../../widgets/app_scaffold.dart';
import 'components/cod_app_bar_bottom.dart';

class CodCollectionScreen extends StatefulWidget {
  const CodCollectionScreen({super.key});

  @override
  State<CodCollectionScreen> createState() => _CodCollectionScreenState();
}

class _CodCollectionScreenState extends State<CodCollectionScreen> {
  late CodCollectionController controller;

  @override
  void initState() {
    Get.delete<CodCollectionController>();
    controller = Get.put(CodCollectionController());
    controller.getCodExpenseList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            pinned: true,
            floating: true,
            title: const Text("Cod Collection"),
            leading: const AppBackButton(),
            bottom: codAppBarBottom(),
          )
        ];
      },
      body: GetBuilder(
          init: CodCollectionController(),
          builder: (controller) {
            return controller.loading.isTrue
                ? circularloadingRedSmallInfinitySize()
                : controller.filterCodExpenseList.isEmpty
                ? const AppEmptyView(message: "No Data Found",)
                :Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(DimensConstants.screePadding),
                          child: const CodExpenseList(),
                        ),
                      ),
                    ],
                  );
          }),
    ));
  }
}
